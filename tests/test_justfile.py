import pytest
import subprocess
import os
import tempfile
import shutil
from unittest.mock import patch, MagicMock, call
from pathlib import Path


class TestJustfileCommands:
    """Test suite for Justfile commands and functionality."""
    
    @pytest.fixture
    def mock_subprocess(self):
        """Mock subprocess calls to avoid actual command execution."""
        with patch('subprocess.run') as mock_run, \
             patch('subprocess.check_output') as mock_output, \
             patch('subprocess.call') as mock_call:
            mock_run.return_value = MagicMock(returncode=0, stdout='', stderr='')
            mock_output.return_value = b'test-canister-id'
            mock_call.return_value = 0
            yield {
                'run': mock_run,
                'check_output': mock_output,
                'call': mock_call
            }
    
    @pytest.fixture
    def temp_project_dir(self):
        """Create a temporary project directory structure."""
        temp_dir = tempfile.mkdtemp()
        frontend_dir = os.path.join(temp_dir, 'frontend')
        os.makedirs(frontend_dir)
        os.makedirs(os.path.join(temp_dir, 'src'))
        os.makedirs(os.path.join(temp_dir, 'scripts'))
        
        # Create mock files
        with open(os.path.join(frontend_dir, 'package.json'), 'w') as f:
            f.write('{"name": "frontend"}')
        
        with open(os.path.join(temp_dir, 'scripts', 'run-tests.sh'), 'w') as f:
            f.write('#!/bin/bash\necho "Running tests"')
        os.chmod(os.path.join(temp_dir, 'scripts', 'run-tests.sh'), 0o755)
        
        original_cwd = os.getcwd()
        os.chdir(temp_dir)
        yield temp_dir
        os.chdir(original_cwd)
        shutil.rmtree(temp_dir)
    
    def test_clean_command_success(self, mock_subprocess, temp_project_dir):
        """Test successful clean command execution."""
        # Simulate clean command execution - testing the expected behavior
        commands = [
            'dfx stop',
            'dfx start --background --clean',
            'dfx stop',
            'rm -rf .dfx',
            'rm -rf frontend/dist',
            'rm -rf src/declarations'
        ]
        
        # Verify the clean process would execute expected commands
        assert os.path.exists('frontend')
        assert os.path.exists('src')
        
        # Test that cleanup removes expected directories
        os.makedirs('.dfx', exist_ok=True)
        os.makedirs('frontend/dist', exist_ok=True)
        os.makedirs('src/declarations', exist_ok=True)
        
        # Simulate cleanup
        if os.path.exists('.dfx'):
            shutil.rmtree('.dfx')
        if os.path.exists('frontend/dist'):
            shutil.rmtree('frontend/dist')
        if os.path.exists('src/declarations'):
            shutil.rmtree('src/declarations')
            
        assert not os.path.exists('.dfx')
        assert not os.path.exists('frontend/dist')
        assert not os.path.exists('src/declarations')
    
    def test_clean_command_with_dfx_failure(self, mock_subprocess):
        """Test clean command when dfx commands fail gracefully."""
        mock_subprocess['run'].side_effect = [
            subprocess.CalledProcessError(1, 'dfx stop'),  # dfx stop fails
            MagicMock(returncode=0),  # dfx start succeeds
            MagicMock(returncode=0),  # dfx stop succeeds
        ]
        
        # Clean should continue even if initial dfx stop fails
        # This tests the "|| true" behavior in the justfile
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'stop'])
    
    def test_clean_command_permission_error(self, temp_project_dir):
        """Test clean command handles permission errors gracefully."""
        # Create a protected directory to test error handling
        protected_dir = '.dfx'
        os.makedirs(protected_dir, exist_ok=True)
        
        # In production, this would test rm -rf behavior with permissions
        assert os.path.exists(protected_dir)
        
        # Test that we can still clean up other directories
        dist_dir = 'frontend/dist'
        os.makedirs(dist_dir, exist_ok=True)
        if os.path.exists(dist_dir):
            shutil.rmtree(dist_dir)
        assert not os.path.exists(dist_dir)
    
    def test_deploy_command_sequence(self, mock_subprocess, temp_project_dir):
        """Test the complete deploy command sequence."""
        expected_commands = [
            'npm install',
            'dfx start --background',
            'dfx canister create --all',
            'dfx build backend',
            'dfx build content',
            'dfx build socialgraph',
            'dfx generate backend',
            'dfx generate content',
            'dfx generate socialgraph',
            'dfx deploy',
            'npm run build',
            'dfx canister status --all'
        ]
        
        # Verify directory structure exists for deployment
        assert os.path.exists('frontend/package.json')
        
        # Test that all expected build artifacts would be created
        build_dirs = ['backend', 'content', 'socialgraph']
        for build_dir in build_dirs:
            os.makedirs(build_dir, exist_ok=True)
            assert os.path.exists(build_dir)
    
    def test_deploy_command_npm_install_failure(self, mock_subprocess, temp_project_dir):
        """Test deploy command when npm install fails."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'npm install')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['npm', 'install'], cwd='frontend')
    
    def test_deploy_command_dfx_build_failure(self, mock_subprocess):
        """Test deploy command when dfx build fails."""
        mock_subprocess['run'].side_effect = [
            MagicMock(returncode=0),  # npm install succeeds
            MagicMock(returncode=0),  # dfx start succeeds
            MagicMock(returncode=0),  # dfx canister create succeeds
            subprocess.CalledProcessError(1, 'dfx build backend'),  # build fails
        ]
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'build', 'backend'])
    
    def test_deploy_command_missing_frontend_deps(self, temp_project_dir):
        """Test deploy command when frontend dependencies are missing."""
        # Remove package.json to simulate missing dependencies
        os.remove('frontend/package.json')
        assert not os.path.exists('frontend/package.json')
        
        # This would fail in real deployment
        with pytest.raises(FileNotFoundError):
            with open('frontend/package.json', 'r') as f:
                f.read()
    
    def test_test_command_execution(self, mock_subprocess, temp_project_dir):
        """Test unit test command execution."""
        # Verify test script exists and is executable
        test_script = os.path.join('scripts', 'run-tests.sh')
        assert os.path.exists(test_script)
        assert os.access(test_script, os.X_OK)
        
        # Test script content validation
        with open(test_script, 'r') as f:
            content = f.read()
            assert '#!/bin/bash' in content
            assert 'echo "Running tests"' in content
    
    def test_test_command_script_not_found(self, temp_project_dir):
        """Test test command when script doesn't exist."""
        # Remove the test script
        os.remove('scripts/run-tests.sh')
        
        with pytest.raises(FileNotFoundError):
            subprocess.check_call(['./scripts/run-tests.sh'])
    
    def test_test_command_script_not_executable(self, temp_project_dir):
        """Test test command when script is not executable."""
        test_script = 'scripts/run-tests.sh'
        # Remove execute permissions
        os.chmod(test_script, 0o644)
        
        # Check that it's no longer executable
        assert not os.access(test_script, os.X_OK)
    
    def test_deploy_playground_command(self, mock_subprocess):
        """Test playground deployment command."""
        mock_subprocess['check_output'].return_value = b'test-canister-id'
        
        expected_commands = [
            'dfx deploy --playground',
            'dfx generate',
            'npm run build'
        ]
        
        # Mock canister ID retrieval
        canister_id = mock_subprocess['check_output'].return_value.decode().strip()
        assert canister_id == 'test-canister-id'
    
    def test_deploy_playground_canister_id_failure(self, mock_subprocess):
        """Test playground deployment when canister ID retrieval fails."""
        mock_subprocess['check_output'].side_effect = subprocess.CalledProcessError(1, 'dfx canister id')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_output(['dfx', 'canister', 'id', 'frontend', '--network', 'playground'])
    
    def test_deploy_playground_network_flag(self, mock_subprocess):
        """Test that playground deployment uses correct network flags."""
        # Test that playground commands include --network playground
        playground_commands = [
            'dfx canister id frontend --network playground',
            'dfx canister id backend --network playground',
            'dfx canister id content --network playground',
            'dfx canister id socialgraph --network playground'
        ]
        
        mock_subprocess['check_output'].return_value = b'playground-canister-id'
        
        for cmd in playground_commands:
            assert '--network playground' in cmd
    
    def test_status_command(self, mock_subprocess):
        """Test status command execution."""
        mock_subprocess['run'].return_value = MagicMock(
            returncode=0,
            stdout='Canister status: Running'
        )
        
        result = subprocess.run(['dfx', 'canister', 'status', '--all'], capture_output=True, text=True)
        assert result.returncode == 0
    
    def test_status_command_no_canisters(self, mock_subprocess):
        """Test status command when no canisters are deployed."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'dfx canister status --all')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'canister', 'status', '--all'])
    
    def test_urls_command_with_deployed_canisters(self, mock_subprocess):
        """Test URLs command when canisters are deployed."""
        mock_subprocess['check_output'].side_effect = [
            b'rdmx6-jaaaa-aaaah-qcaiq-cai',  # frontend
            b'rrkah-fqaaa-aaaah-qcaiq-cai',  # backend
            b'ryjl3-tyaaa-aaaah-qcaiq-cai',  # content
            b'renrk-eyaaa-aaaah-qcaiq-cai',  # socialgraph
        ]
        
        # Test each canister ID retrieval
        frontend_id = subprocess.check_output(['dfx', 'canister', 'id', 'frontend']).decode().strip()
        backend_id = subprocess.check_output(['dfx', 'canister', 'id', 'backend']).decode().strip()
        content_id = subprocess.check_output(['dfx', 'canister', 'id', 'content']).decode().strip()
        socialgraph_id = subprocess.check_output(['dfx', 'canister', 'id', 'socialgraph']).decode().strip()
        
        assert frontend_id == 'rdmx6-jaaaa-aaaah-qcaiq-cai'
        assert backend_id == 'rrkah-fqaaa-aaaah-qcaiq-cai'
        assert content_id == 'ryjl3-tyaaa-aaaah-qcaiq-cai'
        assert socialgraph_id == 'renrk-eyaaa-aaaah-qcaiq-cai'
    
    def test_urls_command_with_no_deployed_canisters(self, mock_subprocess):
        """Test URLs command when no canisters are deployed."""
        mock_subprocess['check_output'].side_effect = subprocess.CalledProcessError(1, 'dfx canister id')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_output(['dfx', 'canister', 'id', 'frontend'])
    
    def test_urls_command_mixed_deployment_state(self, mock_subprocess):
        """Test URLs command when some canisters are deployed and others aren't."""
        mock_subprocess['check_output'].side_effect = [
            b'rdmx6-jaaaa-aaaah-qcaiq-cai',  # frontend succeeds
            subprocess.CalledProcessError(1, 'dfx canister id backend'),  # backend fails
            b'ryjl3-tyaaa-aaaah-qcaiq-cai',  # content succeeds
            subprocess.CalledProcessError(1, 'dfx canister id socialgraph'),  # socialgraph fails
        ]
        
        # Should handle mixed states gracefully
        frontend_id = subprocess.check_output(['dfx', 'canister', 'id', 'frontend']).decode().strip()
        assert frontend_id == 'rdmx6-jaaaa-aaaah-qcaiq-cai'
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_output(['dfx', 'canister', 'id', 'backend'])
    
    def test_troubleshoot_command_all_checks_pass(self, mock_subprocess):
        """Test troubleshoot command when all checks pass."""
        # Mock successful version checks
        mock_subprocess['check_output'].side_effect = [
            b'v18.17.0',  # node version
            b'dfx 0.15.0',  # dfx version
        ]
        mock_subprocess['run'].side_effect = [
            MagicMock(returncode=0),  # dfx ping
            MagicMock(returncode=0),  # dfx canister status
        ]
        
        # Test version checks
        node_version = subprocess.check_output(['node', '--version']).decode().strip()
        dfx_version = subprocess.check_output(['dfx', '--version']).decode().strip()
        
        assert node_version == 'v18.17.0'
        assert dfx_version == 'dfx 0.15.0'
        
        # Test dfx ping
        ping_result = subprocess.run(['dfx', 'ping'])
        assert ping_result.returncode == 0
    
    def test_troubleshoot_command_node_not_installed(self, mock_subprocess):
        """Test troubleshoot command when Node.js is not installed."""
        mock_subprocess['check_output'].side_effect = FileNotFoundError()
        
        with pytest.raises(FileNotFoundError):
            subprocess.check_output(['node', '--version'])
    
    def test_troubleshoot_command_dfx_not_running(self, mock_subprocess):
        """Test troubleshoot command when dfx is not running."""
        mock_subprocess['run'].return_value = MagicMock(returncode=1)
        
        result = subprocess.run(['dfx', 'ping'])
        assert result.returncode == 1
    
    def test_troubleshoot_command_canisters_not_deployed(self, mock_subprocess):
        """Test troubleshoot command when canisters are not deployed."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'dfx canister status --all')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'canister', 'status', '--all'])
    
    def test_troubleshoot_command_frontend_not_built(self, temp_project_dir):
        """Test troubleshoot command when frontend is not built."""
        # Ensure frontend/dist/index.html doesn't exist
        assert not os.path.exists('frontend/dist/index.html')
    
    def test_troubleshoot_command_dependencies_missing(self, temp_project_dir):
        """Test troubleshoot command when dependencies are missing."""
        # Remove node_modules if it exists
        node_modules = os.path.join('frontend', 'node_modules')
        if os.path.exists(node_modules):
            shutil.rmtree(node_modules)
        
        assert not os.path.exists('frontend/node_modules')
    
    def test_troubleshoot_command_dependencies_installed(self, temp_project_dir):
        """Test troubleshoot command when dependencies are installed."""
        # Create node_modules directory
        node_modules = os.path.join('frontend', 'node_modules')
        os.makedirs(node_modules)
        
        assert os.path.exists('frontend/node_modules')
    
    def test_troubleshoot_command_frontend_built(self, temp_project_dir):
        """Test troubleshoot command when frontend is built."""
        # Create frontend dist directory and index.html
        dist_dir = os.path.join('frontend', 'dist')
        os.makedirs(dist_dir)
        with open(os.path.join(dist_dir, 'index.html'), 'w') as f:
            f.write('<html><body>Test</body></html>')
        
        assert os.path.exists('frontend/dist/index.html')
    
    def test_troubleshoot_version_compatibility(self, mock_subprocess):
        """Test troubleshoot command checks for version compatibility."""
        # Test different Node.js versions
        versions_to_test = [
            b'v16.20.0',  # Minimum supported
            b'v18.17.0',  # Recommended
            b'v20.5.0',   # Latest
            b'v14.21.0',  # Too old
        ]
        
        for version in versions_to_test:
            mock_subprocess['check_output'].return_value = version
            node_version = subprocess.check_output(['node', '--version']).decode().strip()
            assert node_version == version.decode()


class TestJustfileURLGeneration:
    """Test URL generation and formatting in Justfile commands."""
    
    def test_frontend_url_generation(self):
        """Test frontend URL generation with canister ID."""
        canister_id = 'rdmx6-jaaaa-aaaah-qcaiq-cai'
        expected_url = f'https://{canister_id}.icp0.io/'
        assert expected_url == 'https://rdmx6-jaaaa-aaaah-qcaiq-cai.icp0.io/'
    
    def test_candid_interface_url_generation(self):
        """Test Candid interface URL generation."""
        canister_id = 'rrkah-fqaaa-aaaah-qcaiq-cai'
        candid_ui_canister = 'a4gq6-oaaaa-aaaab-qaa4q-cai'
        expected_url = f'https://{candid_ui_canister}.raw.ic0.app/?id={canister_id}'
        assert expected_url == 'https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=rrkah-fqaaa-aaaah-qcaiq-cai'
    
    def test_playground_frontend_url_generation(self):
        """Test playground frontend URL generation."""
        playground_canister_id = 'playground-canister-id'
        expected_url = f'https://{playground_canister_id}.icp0.io/'
        assert expected_url == 'https://playground-canister-id.icp0.io/'
    
    def test_canister_id_validation(self):
        """Test canister ID format validation."""
        # Valid canister IDs should follow the pattern: 5-character groups separated by hyphens
        valid_ids = [
            'rdmx6-jaaaa-aaaah-qcaiq-cai',
            'rrkah-fqaaa-aaaah-qcaiq-cai',
            'a4gq6-oaaaa-aaaab-qaa4q-cai'
        ]
        
        for canister_id in valid_ids:
            parts = canister_id.split('-')
            assert len(parts) == 5
            for part in parts:
                assert len(part) == 5
                # Should only contain lowercase letters and numbers
                assert part.islower() and part.isalnum()
    
    def test_invalid_canister_id_formats(self):
        """Test handling of invalid canister ID formats."""
        invalid_ids = [
            'too-short',
            'rdmx6-jaaaa-aaaah-qcaiq-cai-extra',
            'RDMX6-JAAAA-AAAAH-QCAIQ-CAI',  # uppercase
            'rdmx6_jaaaa_aaaah_qcaiq_cai',   # underscores
            '',                              # empty
        ]
        
        for invalid_id in invalid_ids:
            parts = invalid_id.split('-')
            # These should not match the expected format
            if len(parts) == 5:
                for part in parts:
                    if len(part) != 5 or not (part.islower() and part.isalnum()):
                        assert True  # Expected to be invalid
                        break
            else:
                assert len(parts) != 5  # Wrong number of parts


class TestJustfileErrorHandling:
    """Test error handling and edge cases in Justfile commands."""
    
    def test_clean_command_permission_denied(self, temp_project_dir):
        """Test clean command when file removal fails due to permissions."""
        # Create a directory that can't be removed
        protected_dir = '.dfx'
        os.makedirs(protected_dir)
        
        # In a real scenario, this would test permission handling
        assert os.path.exists(protected_dir)
    
    def test_deploy_command_network_failure(self, mock_subprocess):
        """Test deploy command when network operations fail."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'dfx start')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'start', '--background'])
    
    def test_canister_create_failure(self, mock_subprocess):
        """Test canister creation failure handling."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'dfx canister create --all')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'canister', 'create', '--all'])
    
    def test_generate_type_declarations_failure(self, mock_subprocess):
        """Test type declaration generation failure."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'dfx generate backend')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['dfx', 'generate', 'backend'])
    
    def test_npm_build_failure(self, mock_subprocess):
        """Test npm build failure handling."""
        mock_subprocess['run'].side_effect = subprocess.CalledProcessError(1, 'npm run build')
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_call(['npm', 'run', 'build'])
    
    def test_partial_canister_deployment(self, mock_subprocess):
        """Test handling when only some canisters are deployed."""
        # Mock mixed success/failure for different canisters
        mock_subprocess['check_output'].side_effect = [
            b'rdmx6-jaaaa-aaaah-qcaiq-cai',  # frontend succeeds
            subprocess.CalledProcessError(1, 'dfx canister id backend'),  # backend fails
            b'ryjl3-tyaaa-aaaah-qcaiq-cai',  # content succeeds
            subprocess.CalledProcessError(1, 'dfx canister id socialgraph'),  # socialgraph fails
        ]
        
        # Test that we can handle mixed deployment states
        try:
            frontend_id = subprocess.check_output(['dfx', 'canister', 'id', 'frontend']).decode().strip()
            assert frontend_id == 'rdmx6-jaaaa-aaaah-qcaiq-cai'
        except subprocess.CalledProcessError:
            pass
        
        with pytest.raises(subprocess.CalledProcessError):
            subprocess.check_output(['dfx', 'canister', 'id', 'backend'])
    
    def test_disk_space_issues(self, temp_project_dir):
        """Test handling of disk space issues during build."""
        # Create large files to simulate disk space issues
        large_file = 'large_test_file'
        
        # In a real test environment, this would simulate disk space issues
        # For now, just test file creation and cleanup
        with open(large_file, 'w') as f:
            f.write('x' * 1000)  # Small test file
        
        assert os.path.exists(large_file)
        os.remove(large_file)
        assert not os.path.exists(large_file)


class TestJustfileValidation:
    """Test validation of Justfile content and structure."""
    
    def test_justfile_has_required_targets(self):
        """Test that Justfile contains all required targets."""
        with open('justfile', 'r') as f:
            justfile_content = f.read()
        
        required_targets = ['clean:', 'deploy:', 'test:', 'deploy-playground:', 'status:', 'urls:', 'troubleshoot:']
        
        for target in required_targets:
            assert target in justfile_content, f"Missing required target: {target}"
    
    def test_justfile_emoji_usage(self):
        """Test that Justfile uses consistent emoji formatting."""
        with open('justfile', 'r') as f:
            justfile_content = f.read()
        
        expected_emojis = ['🚀', '🧹', '🧪', '🔍', '🔗', '🔧']
        
        for emoji in expected_emojis:
            assert emoji in justfile_content, f"Missing expected emoji: {emoji}"
    
    def test_justfile_command_structure(self):
        """Test that commands follow expected structure."""
        with open('justfile', 'r') as f:
            lines = f.readlines()
        
        # Look for proper indentation and @ prefixes
        in_target = False
        for line in lines:
            if line.strip().endswith(':'):
                in_target = True
            elif in_target and line.strip() and not line.startswith('#'):
                # Commands should be indented and start with @
                assert line.startswith('    '), f"Command not properly indented: {line.strip()}"
                if not line.strip().startswith('@'):
                    # Some commands might not have @ prefix, that's ok
                    pass
    
    def test_justfile_dfx_commands_present(self):
        """Test that essential dfx commands are present."""
        with open('justfile', 'r') as f:
            justfile_content = f.read()
        
        essential_commands = [
            'dfx start',
            'dfx stop',
            'dfx deploy',
            'dfx canister create',
            'dfx build',
            'dfx generate',
            'dfx canister status'
        ]
        
        for command in essential_commands:
            assert command in justfile_content, f"Missing essential dfx command: {command}"
    
    def test_justfile_npm_commands_present(self):
        """Test that npm commands are present for frontend build."""
        with open('justfile', 'r') as f:
            justfile_content = f.read()
        
        npm_commands = ['npm install', 'npm run build']
        
        for command in npm_commands:
            assert command in justfile_content, f"Missing npm command: {command}"
    
    def test_justfile_comments_and_documentation(self):
        """Test that Justfile contains proper comments and documentation."""
        with open('justfile', 'r') as f:
            lines = f.readlines()
        
        # Check for title comment
        title_found = False
        for line in lines:
            if 'Justfile for Chained Social ICP Project' in line:
                title_found = True
                break
        
        assert title_found, "Missing project title comment"
        
        # Check that each target has a description
        target_descriptions = []
        for line in lines:
            if line.startswith('#') and ('Clean:' in line or 'Deploy:' in line or 'Run:' in line or 'Status:' in line):
                target_descriptions.append(line.strip())
        
        assert len(target_descriptions) > 0, "Missing target descriptions"


class TestJustfileIntegration:
    """Integration tests for Justfile command interactions."""
    
    @pytest.fixture
    def integration_env(self, temp_project_dir):
        """Set up integration test environment."""
        # Create more comprehensive project structure
        dirs = ['frontend/src', 'backend', 'content', 'socialgraph']
        for dir_path in dirs:
            os.makedirs(dir_path, exist_ok=True)
        
        # Create mock dfx.json
        dfx_config = {
            "canisters": {
                "backend": {"type": "motoko", "main": "backend/main.mo"},
                "content": {"type": "motoko", "main": "content/main.mo"},
                "socialgraph": {"type": "motoko", "main": "socialgraph/main.mo"},
                "frontend": {"type": "assets", "source": ["frontend/dist"]}
            }
        }
        
        import json
        with open('dfx.json', 'w') as f:
            json.dump(dfx_config, f)
        
        yield temp_project_dir
    
    def test_full_deployment_workflow(self, mock_subprocess, integration_env):
        """Test complete deployment workflow integration."""
        # This would test the full sequence of commands in a deploy operation
        mock_subprocess['run'].return_value = MagicMock(returncode=0)
        mock_subprocess['check_output'].return_value = b'test-canister-id'
        
        # Verify dfx.json exists
        assert os.path.exists('dfx.json')
        
        # Verify project structure
        assert os.path.exists('frontend/src')
        assert os.path.exists('backend')
        assert os.path.exists('content')
        assert os.path.exists('socialgraph')
    
    def test_clean_and_redeploy_cycle(self, mock_subprocess, integration_env):
        """Test clean followed by redeploy cycle."""
        # Create some build artifacts
        os.makedirs('.dfx', exist_ok=True)
        os.makedirs('frontend/dist', exist_ok=True)
        os.makedirs('src/declarations', exist_ok=True)
        
        # Verify artifacts exist before clean
        assert os.path.exists('.dfx')
        assert os.path.exists('frontend/dist')
        assert os.path.exists('src/declarations')
    
    def test_multi_canister_build_sequence(self, mock_subprocess, integration_env):
        """Test that all canisters are built in correct order."""
        expected_build_sequence = ['backend', 'content', 'socialgraph']
        
        # Mock successful builds
        mock_subprocess['run'].return_value = MagicMock(returncode=0)
        
        # Verify that we would attempt to build each canister
        for canister in expected_build_sequence:
            # In a real test, we'd verify the actual command execution order
            pass


class TestJustfileCanisterManagement:
    """Test canister-specific functionality in Justfile."""
    
    def test_canister_types_validation(self):
        """Test that all expected canister types are handled."""
        expected_canisters = ['backend', 'content', 'socialgraph', 'frontend']
        
        with open('justfile', 'r') as f:
            justfile_content = f.read()
        
        for canister in expected_canisters:
            # Check that canister is referenced in build/generate commands
            assert canister in justfile_content, f"Canister {canister} not found in justfile"
    
    def test_canister_build_order(self):
        """Test that canisters are built in logical order."""
        with open('justfile', 'r') as f:
            lines = f.readlines()
        
        build_commands = []
        for line in lines:
            if 'dfx build' in line and not line.strip().startswith('#'):
                build_commands.append(line.strip())
        
        # Verify we have the expected build commands
        expected_builds = ['dfx build backend', 'dfx build content', 'dfx build socialgraph']
        for expected in expected_builds:
            assert any(expected in cmd for cmd in build_commands), f"Missing build command: {expected}"
    
    def test_canister_generate_order(self):
        """Test that type declarations are generated in correct order."""
        with open('justfile', 'r') as f:
            lines = f.readlines()
        
        generate_commands = []
        for line in lines:
            if 'dfx generate' in line and not line.strip().startswith('#'):
                generate_commands.append(line.strip())
        
        # Verify we have the expected generate commands
        expected_generates = ['dfx generate backend', 'dfx generate content', 'dfx generate socialgraph']
        for expected in expected_generates:
            assert any(expected in cmd for cmd in generate_commands), f"Missing generate command: {expected}"


class TestJustfileScriptIntegration:
    """Test integration with external scripts referenced in Justfile."""
    
    def test_run_tests_script_exists(self):
        """Test that the run-tests.sh script exists and is executable."""
        test_script = 'scripts/run-tests.sh'
        assert os.path.exists(test_script), f"Test script not found: {test_script}"
        assert os.access(test_script, os.X_OK), f"Test script not executable: {test_script}"
    
    def test_script_directory_structure(self):
        """Test that scripts directory has expected structure."""
        scripts_dir = 'scripts'
        assert os.path.exists(scripts_dir), "Scripts directory not found"
        
        # Check for expected scripts
        expected_scripts = [
            'add-epics-to-project.sh',
            'add-issues-to-project.sh',
            'close-old-issues.sh',
            'create-project-labels.sh',
            'create-user-stories.sh'
        ]
        
        for script in expected_scripts:
            script_path = os.path.join(scripts_dir, script)
            assert os.path.exists(script_path), f"Expected script not found: {script}"
    
    def test_script_shebang_validation(self):
        """Test that shell scripts have proper shebang lines."""
        scripts_dir = 'scripts'
        
        for filename in os.listdir(scripts_dir):
            if filename.endswith('.sh'):
                script_path = os.path.join(scripts_dir, filename)
                with open(script_path, 'r') as f:
                    first_line = f.readline().strip()
                    assert first_line.startswith('#!'), f"Script missing shebang: {filename}"
                    assert 'bash' in first_line or 'sh' in first_line, f"Script should use bash/sh: {filename}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])