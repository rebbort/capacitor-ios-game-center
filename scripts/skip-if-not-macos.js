if (process.platform !== 'darwin') {
  console.log('Skip iOS native tests on non-macOS host.');
  process.exit(0);
}
const { execSync } = require('child_process');
execSync(
  'xcodebuild -project ios/Plugin/Plugin.xcodeproj -scheme GameCenterPluginTests -destination "platform=iOS Simulator,name=iPhone 14,OS=17.4" clean test',
  { stdio: 'inherit' },
);
