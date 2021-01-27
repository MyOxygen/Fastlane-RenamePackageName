describe Fastlane::Actions::RenamePackageNameAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:user_error!)

      Fastlane::Actions::RenamePackageNameAction.run(nil)
    end
  end
end
