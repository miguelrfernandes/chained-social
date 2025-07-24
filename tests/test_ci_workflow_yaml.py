import unittest
import yaml
import os
import re
from pathlib import Path


class TestCIWorkflowYAML(unittest.TestCase):
    """
    Unit tests for the CI/CD Pipeline workflow YAML configuration.
    
    This test suite validates the structure, syntax, and configuration
    of the GitHub Actions workflow file to ensure it meets requirements
    and follows best practices.
    
    Testing Framework: unittest (Python standard library)
    """
    
    @classmethod
    def setUpClass(cls):
        """Set up test fixtures before running tests."""
        # Find the actual workflow file
        workflow_paths = [
            '.github/workflows/ci.yml',
            '.github/workflows/ci.yaml',
            '.github/workflows/main.yml',
            '.github/workflows/main.yaml'
        ]
        
        cls.workflow_file = None
        for path in workflow_paths:
            if os.path.exists(path):
                cls.workflow_file = path
                break
        
        if cls.workflow_file:
            with open(cls.workflow_file, 'r') as f:
                cls.workflow_content = f.read()
                cls.workflow_data = yaml.safe_load(cls.workflow_content)
        else:
            # Use the provided test data from the source code
            cls.workflow_content = """name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  DFX_VERSION: 0.27.0

jobs:
  security:
    name: 🔐 Security Scan
    runs-on: ubuntu-latest
    
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: 🔍 Run TruffleHog
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --results=verified,unknown

  test-build-deploy:
    name: 🎸 Test, Build, and Deploy
    runs-on: ubuntu-latest
    needs: security
    
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 📦 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: 'package.json'
          cache: 'npm'
          cache-dependency-path: 'package-lock.json'

      - name: 📦 Install just
        uses: taiki-e/install-action@just

      - name: 📦 Install dfx
        uses: dfinity/setup-dfx@main
        with:
          dfx-version: "0.27.0"

      - name: 🚀 Deploy and build
        run: |
          just troubleshoot
          just deploy

      - name: 🧪 Run tests
        run: |
          just test
        continue-on-error: true

      - name: 🔍 Validate deployment
        run: |
          just status

      - name: 📊 Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: |
            test-results/
            *.log
            dfx.log

      - name: 📦 Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            frontend/dist/
            src/declarations/
            .dfx/"""
            cls.workflow_data = yaml.safe_load(cls.workflow_content)

    def test_yaml_syntax_is_valid(self):
        """Test that the YAML file has valid syntax."""
        try:
            yaml.safe_load(self.workflow_content)
        except yaml.YAMLError as e:
            self.fail(f"YAML syntax error: {e}")

    def test_workflow_has_required_top_level_keys(self):
        """Test that the workflow contains all required top-level keys."""
        required_keys = ['name', 'on', 'jobs']
        for key in required_keys:
            with self.subTest(key=key):
                self.assertIn(key, self.workflow_data, 
                            f"Required key '{key}' missing from workflow")

    def test_workflow_name_is_descriptive(self):
        """Test that the workflow has a meaningful name."""
        name = self.workflow_data.get('name', '')
        self.assertTrue(len(name) > 0, "Workflow name should not be empty")
        self.assertIn('CI', name.upper(), "Workflow name should indicate CI/CD purpose")

    def test_trigger_configuration_is_appropriate(self):
        """Test that workflow triggers are properly configured."""
        on_config = self.workflow_data.get('on', {})
        
        # Should trigger on push to main branches
        self.assertIn('push', on_config, "Workflow should trigger on push events")
        push_config = on_config['push']
        self.assertIn('branches', push_config, "Push trigger should specify branches")
        
        branches = push_config['branches']
        self.assertIn('main', branches, "Should trigger on main branch")
        self.assertIn('develop', branches, "Should trigger on develop branch")
        
        # Should trigger on pull requests
        self.assertIn('pull_request', on_config, "Workflow should trigger on pull requests")
        pr_config = on_config['pull_request']
        self.assertIn('branches', pr_config, "PR trigger should specify target branches")

    def test_environment_variables_are_set(self):
        """Test that required environment variables are defined."""
        env = self.workflow_data.get('env', {})
        self.assertIn('DFX_VERSION', env, "DFX_VERSION should be defined")
        
        dfx_version = env['DFX_VERSION']
        self.assertIsInstance(dfx_version, (str, float), "DFX_VERSION should be string or number")
        self.assertTrue(str(dfx_version).replace('.', '').isdigit(), 
                       "DFX_VERSION should be a valid version number")
        
        # Test specific version value
        self.assertEqual(str(dfx_version), '0.27.0', "DFX_VERSION should be 0.27.0")

    def test_jobs_are_properly_defined(self):
        """Test that all jobs are properly configured."""
        jobs = self.workflow_data.get('jobs', {})
        self.assertTrue(len(jobs) >= 2, "At least two jobs should be defined")
        
        # Test security job exists
        self.assertIn('security', jobs, "Security job should be defined")
        security_job = jobs['security']
        self.assertIn('runs-on', security_job, "Security job should specify runner")
        self.assertEqual(security_job['runs-on'], 'ubuntu-latest', 
                        "Security job should run on ubuntu-latest")
        
        # Test main job exists
        self.assertIn('test-build-deploy', jobs, "Main test-build-deploy job should be defined")

    def test_security_job_configuration(self):
        """Test that the security job is properly configured."""
        jobs = self.workflow_data.get('jobs', {})
        security_job = jobs.get('security', {})
        
        # Should have proper name
        self.assertIn('name', security_job, "Security job should have a name")
        self.assertIn('Security', security_job['name'], "Job name should indicate security purpose")
        
        # Should have steps
        self.assertIn('steps', security_job, "Security job should have steps")
        steps = security_job['steps']
        self.assertTrue(len(steps) >= 2, "Security job should have at least 2 steps")
        
        # First step should be checkout with full history
        checkout_step = steps[0]
        self.assertIn('uses', checkout_step, "First step should use an action")
        self.assertTrue(checkout_step['uses'].startswith('actions/checkout'), 
                       "First step should be checkout action")
        
        # Should checkout with full history for security scanning
        with_config = checkout_step.get('with', {})
        self.assertIn('fetch-depth', with_config, "Security checkout should specify fetch depth")
        self.assertEqual(with_config['fetch-depth'], 0, "Should fetch full git history")
        
        # Should have TruffleHog step
        trufflehog_found = False
        for step in steps:
            if 'trufflehog' in step.get('uses', '').lower():
                trufflehog_found = True
                # Check TruffleHog configuration
                self.assertIn('with', step, "TruffleHog step should have configuration")
                th_config = step['with']
                self.assertIn('extra_args', th_config, "TruffleHog should have extra args")
                self.assertIn('verified', th_config['extra_args'], "Should scan for verified secrets")
                break
        
        self.assertTrue(trufflehog_found, "Security job should include TruffleHog scan")

    def test_main_job_dependencies(self):
        """Test that the main job has proper dependencies."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        
        # Should depend on security job
        self.assertIn('needs', main_job, "Main job should have dependencies")
        needs = main_job['needs']
        if isinstance(needs, str):
            needs = [needs]
        self.assertIn('security', needs, "Main job should depend on security job")

    def test_node_setup_is_configured(self):
        """Test that Node.js setup is properly configured."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Find Node.js setup step
        node_step = None
        for step in steps:
            if 'setup-node' in step.get('uses', ''):
                node_step = step
                break
        
        self.assertIsNotNone(node_step, "Node.js setup step should be present")
        
        # Check configuration
        with_config = node_step.get('with', {})
        self.assertIn('node-version-file', with_config, 
                     "Node version should be specified via file")
        self.assertEqual(with_config['node-version-file'], 'package.json',
                        "Node version should come from package.json")
        self.assertIn('cache', with_config, "NPM cache should be enabled")
        self.assertEqual(with_config['cache'], 'npm', "Should use npm cache")
        self.assertIn('cache-dependency-path', with_config, "Cache dependency path should be set")

    def test_dfx_installation_is_configured(self):
        """Test that DFX installation is properly set up."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Find DFX setup step
        dfx_step = None
        for step in steps:
            if 'setup-dfx' in step.get('uses', ''):
                dfx_step = step
                break
        
        self.assertIsNotNone(dfx_step, "DFX setup step should be present")
        
        # Check version consistency
        with_config = dfx_step.get('with', {})
        self.assertIn('dfx-version', with_config, "DFX version should be specified")
        dfx_version = with_config['dfx-version']
        env_version = self.workflow_data.get('env', {}).get('DFX_VERSION')
        self.assertEqual(str(dfx_version), str(env_version), 
                        "DFX version should be consistent between env and step")

    def test_just_installation_is_configured(self):
        """Test that 'just' command runner is properly installed."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Find just installation step
        just_step = None
        for step in steps:
            if 'install-action@just' in step.get('uses', ''):
                just_step = step
                break
        
        self.assertIsNotNone(just_step, "'just' installation step should be present")
        self.assertIn('📦 Install just', just_step.get('name', ''), 
                     "Just install step should have descriptive name")

    def test_build_and_test_steps_exist(self):
        """Test that build and test steps are present and properly configured."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Check for build/deploy step
        build_step_found = False
        test_step_found = False
        validation_step_found = False
        
        for step in steps:
            run_command = step.get('run', '')
            step_name = step.get('name', '')
            
            if 'deploy' in run_command or 'build' in step_name.lower():
                build_step_found = True
                # Should include troubleshoot command
                self.assertIn('just troubleshoot', run_command, 
                             "Build step should include troubleshooting")
                self.assertIn('just deploy', run_command,
                             "Build step should include deployment")
            
            if 'test' in run_command:
                test_step_found = True
                # Test step should allow failures
                self.assertTrue(step.get('continue-on-error', False),
                               "Test step should continue on error")
            
            if 'status' in run_command:
                validation_step_found = True
        
        self.assertTrue(build_step_found, "Build/deploy step should be present")
        self.assertTrue(test_step_found, "Test step should be present")
        self.assertTrue(validation_step_found, "Deployment validation step should be present")

    def test_artifact_upload_configuration(self):
        """Test that artifact upload steps are properly configured."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Find artifact upload steps
        upload_steps = [step for step in steps 
                       if 'upload-artifact' in step.get('uses', '')]
        
        self.assertTrue(len(upload_steps) >= 2, 
                       "Should have at least 2 artifact upload steps")
        
        # Check test results upload
        test_upload = None
        build_upload = None
        
        for step in upload_steps:
            artifact_name = step.get('with', {}).get('name', '')
            if 'test-results' in artifact_name:
                test_upload = step
            elif 'build-artifacts' in artifact_name:
                build_upload = step
        
        # Test results upload should run always
        self.assertIsNotNone(test_upload, "Test results upload step should exist")
        self.assertIn('if', test_upload, "Test results upload should have conditional")
        self.assertEqual(test_upload['if'], 'always()', 
                        "Test results should be uploaded always")
        
        # Check paths for test results
        test_paths = test_upload.get('with', {}).get('path', '')
        self.assertIn('test-results/', test_paths, "Should upload test-results directory")
        self.assertIn('*.log', test_paths, "Should upload log files")
        self.assertIn('dfx.log', test_paths, "Should upload dfx log specifically")
        
        # Build artifacts upload
        self.assertIsNotNone(build_upload, "Build artifacts upload step should exist")
        build_paths = build_upload.get('with', {}).get('path', '')
        self.assertIn('frontend/dist/', build_paths, "Should upload frontend build")
        self.assertIn('src/declarations/', build_paths, "Should upload declarations")
        self.assertIn('.dfx/', build_paths, "Should upload dfx artifacts")

    def test_action_versions_are_pinned(self):
        """Test that GitHub Actions are pinned to specific versions."""
        jobs = self.workflow_data.get('jobs', {})
        
        for job_name, job_config in jobs.items():
            steps = job_config.get('steps', [])
            for step_idx, step in enumerate(steps):
                if 'uses' in step:
                    action = step['uses']
                    with self.subTest(job=job_name, step=step_idx, action=action):
                        # Should have version specified (@ followed by version)
                        self.assertIn('@', action, 
                                    f"Action {action} should be pinned to a version")
                        
                        # Check specific versions for critical actions
                        if 'actions/checkout' in action:
                            self.assertTrue(action.endswith('@v4'), 
                                          "Checkout action should use v4")
                        elif 'actions/setup-node' in action:
                            self.assertTrue(action.endswith('@v4'),
                                          "Setup-node action should use v4")
                        elif 'actions/upload-artifact' in action:
                            self.assertTrue(action.endswith('@v4'),
                                          "Upload-artifact action should use v4")

    def test_continue_on_error_usage(self):
        """Test appropriate usage of continue-on-error."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Find steps with continue-on-error
        continue_steps = [step for step in steps 
                         if step.get('continue-on-error')]
        
        # Should be used only for test step
        self.assertEqual(len(continue_steps), 1, 
                        "Only one step should use continue-on-error")
        
        test_step = continue_steps[0]
        run_command = test_step.get('run', '')
        self.assertIn('just test', run_command, 
                     "continue-on-error should be used for test step")

    def test_commented_sections_structure(self):
        """Test that commented sections maintain proper structure."""
        lines = self.workflow_content.split('\n')
        
        # Look for commented deployment section
        playground_deploy_found = False
        playground_urls_found = False
        
        for line in lines:
            if '# - name: 🚀 Deploy to playground' in line:
                playground_deploy_found = True
            elif '# - name: 📋 Get playground URLs' in line:
                playground_urls_found = True
        
        self.assertTrue(playground_deploy_found, 
                       "Commented playground deployment section should exist")
        self.assertTrue(playground_urls_found,
                       "Commented playground URLs section should exist")

    def test_step_naming_conventions(self):
        """Test that steps follow consistent naming conventions."""
        jobs = self.workflow_data.get('jobs', {})
        
        emoji_pattern = re.compile(r'^[^\w\s]')  # Starts with non-alphanumeric character (emoji)
        
        for job_name, job_config in jobs.items():
            steps = job_config.get('steps', [])
            for step in steps:
                if 'name' in step:
                    step_name = step['name']
                    with self.subTest(job=job_name, step=step_name):
                        # Should not be empty
                        self.assertTrue(len(step_name.strip()) > 0, 
                                      "Step name should not be empty")
                        
                        # Should start with emoji
                        self.assertTrue(emoji_pattern.match(step_name), 
                                      f"Step name '{step_name}' should start with emoji")

    def test_job_isolation_and_dependencies(self):
        """Test that jobs are properly isolated and have correct dependencies."""
        jobs = self.workflow_data.get('jobs', {})
        
        # Security job should have no dependencies
        security_job = jobs.get('security', {})
        self.assertNotIn('needs', security_job, 
                        "Security job should not depend on other jobs")
        
        # Main job should depend only on security
        main_job = jobs.get('test-build-deploy', {})
        self.assertIn('needs', main_job, "Main job should have dependencies")
        needs = main_job['needs']
        if isinstance(needs, str):
            needs = [needs]
        self.assertEqual(len(needs), 1, "Main job should depend on exactly one job")
        self.assertEqual(needs[0], 'security', "Main job should depend on security job")

    def test_ubuntu_latest_runner_usage(self):
        """Test that jobs use ubuntu-latest runner appropriately."""
        jobs = self.workflow_data.get('jobs', {})
        
        for job_name, job_config in jobs.items():
            with self.subTest(job=job_name):
                self.assertIn('runs-on', job_config, 
                            f"Job {job_name} should specify a runner")
                runner = job_config['runs-on']
                self.assertEqual(runner, 'ubuntu-latest', 
                               f"Job {job_name} should use ubuntu-latest for consistency")

    def test_workflow_structure_best_practices(self):
        """Test adherence to GitHub Actions workflow best practices."""
        jobs = self.workflow_data.get('jobs', {})
        
        for job_name, job_config in jobs.items():
            steps = job_config.get('steps', [])
            
            # First step should be checkout
            if steps:
                first_step = steps[0]
                with self.subTest(job=job_name):
                    self.assertTrue('checkout' in first_step.get('uses', ''), 
                                  f"First step in {job_name} should be checkout")

    def test_security_scan_configuration(self):
        """Test specific security scanning configuration."""
        jobs = self.workflow_data.get('jobs', {})
        security_job = jobs.get('security', {})
        steps = security_job.get('steps', [])
        
        # Find TruffleHog step
        trufflehog_step = None
        for step in steps:
            if 'trufflehog' in step.get('uses', '').lower():
                trufflehog_step = step
                break
        
        self.assertIsNotNone(trufflehog_step, "TruffleHog step should exist")
        
        # Check that it uses main branch (latest version)
        self.assertTrue(trufflehog_step['uses'].endswith('@main'), 
                       "TruffleHog should use @main for latest features")
        
        # Check extra args configuration
        extra_args = trufflehog_step.get('with', {}).get('extra_args', '')
        self.assertIn('verified', extra_args, "Should include verified results")
        self.assertIn('unknown', extra_args, "Should include unknown results")

    def test_deployment_workflow_logic(self):
        """Test the logical flow of deployment steps."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Extract step names in order
        step_names = [step.get('name', '') for step in steps]
        
        # Check logical order
        checkout_idx = next((i for i, name in enumerate(step_names) if 'Checkout' in name), -1)
        node_setup_idx = next((i for i, name in enumerate(step_names) if 'Node.js' in name), -1)
        deploy_idx = next((i for i, name in enumerate(step_names) if 'Deploy' in name), -1)
        test_idx = next((i for i, name in enumerate(step_names) if 'tests' in name), -1)
        validate_idx = next((i for i, name in enumerate(step_names) if 'Validate' in name), -1)
        
        # Verify order
        self.assertTrue(checkout_idx < node_setup_idx, "Checkout should come before Node setup")
        self.assertTrue(node_setup_idx < deploy_idx, "Node setup should come before deploy")
        self.assertTrue(deploy_idx < test_idx, "Deploy should come before tests")
        self.assertTrue(test_idx < validate_idx, "Tests should come before validation")

    def test_conditional_logic_for_pr_deployment(self):
        """Test that commented PR deployment logic is properly structured."""
        lines = self.workflow_content.split('\n')
        
        # Look for PR-specific conditional logic
        pr_conditional_found = False
        github_step_summary_found = False
        
        for line in lines:
            if "github.event_name == 'pull_request'" in line:
                pr_conditional_found = True
            elif 'GITHUB_STEP_SUMMARY' in line:
                github_step_summary_found = True
        
        self.assertTrue(pr_conditional_found, 
                       "PR-specific conditional logic should be present")
        self.assertTrue(github_step_summary_found,
                       "GitHub step summary usage should be present")

    def test_error_handling_and_resilience(self):
        """Test that the workflow handles errors appropriately."""
        jobs = self.workflow_data.get('jobs', {})
        main_job = jobs.get('test-build-deploy', {})
        steps = main_job.get('steps', [])
        
        # Check that test results are uploaded even on failure
        test_upload_step = None
        for step in steps:
            if ('upload-artifact' in step.get('uses', '') and 
                'test-results' in step.get('with', {}).get('name', '')):
                test_upload_step = step
                break
        
        self.assertIsNotNone(test_upload_step, "Test upload step should exist")
        self.assertEqual(test_upload_step.get('if'), 'always()',
                        "Test results should be uploaded even on failure")
        
        # Check that tests can fail without stopping the workflow
        test_step = None
        for step in steps:
            if 'just test' in step.get('run', ''):
                test_step = step
                break
        
        self.assertIsNotNone(test_step, "Test step should exist")
        self.assertTrue(test_step.get('continue-on-error', False),
                       "Test step should continue on error")


if __name__ == '__main__':
    # Run with verbose output to see individual test results
    unittest.main(verbosity=2)