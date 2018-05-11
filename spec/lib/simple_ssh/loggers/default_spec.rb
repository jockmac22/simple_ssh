require "spec_helper"

module SimpleSsh
  module Loggers
    RSpec.describe Default do
      let(:logger) { Default.new }

      it "generates DEBUG output" do
        expect { logger.debug('foo') }.to output("DEBUG: foo\n").to_stdout
      end

      it "generates INFO output" do
        expect { logger.info('foo') }.to output("INFO: foo\n").to_stdout
      end

      it "generates WARN output" do
        expect { logger.warn('foo') }.to output("WARN: foo\n").to_stdout
      end

      it "generates ERROR output" do
        expect { logger.error('foo') }.to output("ERROR: foo\n").to_stdout
      end
    end
  end
end
