module Dpl
  module Providers
    class CloudFoundry < Provider
      summary 'CloudFoundry deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER',       'Bluemix username', required: true
      opt '--password PASS',       'Bluemix password', required: true
      opt '--organization ORG',    'Bluemix target organization', required: true
      opt '--space SPACE',         'Bluemix target space', required: true
      opt '--region REGION',       'Bluemix region', default: 'ng', enum: %w(ng eu-gb eu-de au-syd)
      opt '--api URL',             'Bluemix api URL', required: true
      opt '--app_name APP',        'Application name'
      opt '--manifest FILE',       'Path to the manifest'
      opt '--skip_ssl_validation', 'Skip SSL validation'

      CMDS = {
        install: 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz',
        api:     './cf api %{api} %{skip_ssl_validation_opt}',
        login:   './cf login -u %{username} -p %{password} -o %{organization} -s %{space}',
        push:    './cf push %{push_args}',
        logout:  './cf logout'
      }

      ASSERT = {
        push: 'Failed to push app'
      }

      MSGS = {
        manifest_missing: 'Application must have a manifest.yml for unattended deployment'
      }

      def install
        shell :install
      end

      def validate
        error :manifest_missing if manifest? && manifest_missing?
      end

      def login
        shell :api
        shell :login
      end

      def deploy
        shell :push, assert: true
      end

      def finish
        shell :logout
      end

      private

        def push_args
          args = []
          args << quote(app_name)  if app_name?
          args << "-f #{manifest}" if manifest?
          args.join(' ')
        end

        def skip_ssl_validation_opt
          '--skip-ssl-validation' if skip_ssl_validation?
        end

        def manifest_missing?
          !File.exists?(manifest)
        end
    end
  end
end