describe Fastlane::Actions::RenamePackageNameAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The rename_package_name plugin is working!")

      Fastlane::Actions::RenamePackageNameAction.run(nil)
    end
  end
end
