require 'spec_helper'

describe 'bash' do
  context "when bash version is < 4" do
    before { system "docker pull bash:3 >/dev/null" }

    it "errors gracefully" do
      command = "docker run --rm -v $PWD:/app bash:3 bash /app/download"

      Dir.chdir "examples/minimal" do
        expect(`#{command} 2>&1`).to match_approval('bash/error')
      end
    end
  end
end
