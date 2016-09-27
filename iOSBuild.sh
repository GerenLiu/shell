#如果发现打出的包开启后闪退，可能是丢失文件导致的。此时需要清空xcode的缓存目录。
#一般位于该目录下：~/Library/Developer/Xcode/DerivedData
export LC_COLLATE='C'
export LC_CTYPE='C'
export LC_CTYPE=en_US.UTF-8


workSpace=/Users/wangwei/Documents/Project/iOS/xiangmu_test
buildNumber=1
svnUrl="xxxx"
buildType=
buildEnv=
appVersion=1
appName=xiangmu
jobName=
domain=

xcodePath=/usr/bin
sdkDevice="iphoneos8.4"
sdkSiumlator="iphonesimulator8.4"
projectName="xiangmu"
runTarget="xiangmu"
configuration="Debug"
desPath="iphone"


#默认将渠道改成appstore
echo "appstore" > $workSpace/$desPath/Resource/Data/channel.txt
#更改buildnumber
echo "$buildNumber" > $workSpace/$desPath/Resource/Data/buildnumber.txt

BUNDLE_IDENTIFIER="com.wangwei.xiangmu"
CODE_SIGN_IDENTITY='iPhone Developer: Wei Wang (XXXXXXX)'
PROVISIONING_PROFILE="8a957752-6520-46ba-9493-fa39abbed75c" #DEBUG

sed -i '' "s/com\.baidu\.xiangmu/${BUNDLE_IDENTIFIER}/g" $workSpace/$desPath/xiangmu/xiangmu/xiangmu-Info.plist
sed -i '' "s/com\.wangwei\.xiangmu/${BUNDLE_IDENTIFIER}/g" $workSpace/$desPath/xiangmu/xiangmu/xiangmu-Info.plist
sed -i '' "s/com\.baidu\.KS\.xiangmu/${BUNDLE_IDENTIFIER}/g" $workSpace/$desPath/xiangmu/xiangmu/xiangmu-Info.plist
sed -i '' "s/com\.baidu\.ksnative/${BUNDLE_IDENTIFIER}/g" $workSpace/$desPath/xiangmu/xiangmu/xiangmu-Info.plist

echo "Build and Archive Run Target..."

#clean
echo "------The following is the clean command------"
echo "${xcodePath}/xcodebuild" -project "$workSpace/$desPath/xiangmu.xcodeproj" \
-target "$runTarget" \
-configuration "$configuration" \
-sdk "$sdkDevice" \
clean \
|| echo "Clean Run Target error"  
echo ""

echo "------begin cleaning------"
"${xcodePath}/xcodebuild" -project "$workSpace/$desPath/xiangmu.xcodeproj" \
-target "$runTarget" \
-configuration "$configuration" \
-sdk "$sdkDevice" \
clean \
|| echo "Clean Run Target error"
echo ""

#build
echo "------The following is the build command------"
echo "${xcodePath}/xcodebuild" -workspace "$workSpace/$desPath/xiangmu.xcworkspace" \
-scheme xiangmu \
-configuration "$configuration" \
-sdk "$sdkDevice" \
ARCHS=\"armv7 arm64\" \
BUILD_DIR="${workSpace}/$desPath/build" \
configuration_BUILD_DIR="${workSpace}/$desPath/build/${configuration}-iphoneos" \
ONLY_ACTIVE_ARCH=NO \
CODE_SIGN_IDENTITY=\"${CODE_SIGN_IDENTITY}\" \
PROVISIONING_PROFILE="${PROVISIONING_PROFILE}"
echo ""

echo "------begin building------"
"${xcodePath}/xcodebuild" -workspace "$workSpace/$desPath/xiangmu.xcworkspace" \
-scheme xiangmu \
-configuration "$configuration" \
-sdk "$sdkDevice" \
ARCHS='armv7 arm64' \
VALID_ARCHS='armv7 arm64' \
BUILD_DIR="${workSpace}/$desPath/build" \
configuration_BUILD_DIR="${workSpace}/$desPath/build/${configuration}-iphoneos" \
ONLY_ACTIVE_ARCH=NO \
CODE_SIGN_IDENTITY='${CODE_SIGN_IDENTITY}' \
PROVISIONING_PROFILE=${PROVISIONING_PROFILE} \
|| echo "Build Run Target failed"
echo ""

#package
echo "------the following is the package command------"
echo "${xcodePath}/xcrun" -sdk "$sdkDevice" \
PackageApplication -v $workSpace/$desPath/build/"$configuration"-iphoneos/"$projectName".app \
-o $workSpace/$desPath/build/"$configuration"-iphoneos/${projectName}.ipa \
|| echo "Package ipa failed"
echo ""

echo "------begin package------"
"${xcodePath}/xcrun" -sdk "$sdkDevice" \
PackageApplication -v $workSpace/$desPath/build/"$configuration"-iphoneos/"$projectName".app \
-o $workSpace/$desPath/build/"$configuration"-iphoneos/${projectName}.ipa \
|| echo "Package ipa failed"
echo ""

echo "------copy the ipa to the output directory------"
cd $workSpace/$desPath/build/"$configuration"-iphoneos

#making dsym zip
cp ${projectName}.ipa $workSpace/output/"${projectName}_${buildNumber}".ipa
zip -r "$projectName"_app.zip "$projectName".app
zip -r "$projectName"_app_dSYM.zip "$projectName".app.dSYM
cp "$projectName"_app.zip $workSpace/output/"${projectName}_${buildNumber}"_app.zip
cp "$projectName"_app_dSYM.zip $workSpace/output/"${projectName}_${buildNumber}"_app_dSYM.zip
cd $workSpace/output/ && rm -rf dsym.tar.gz && tar -czf output.tar.gz * && rm -rf *.ipa *.zip 

# 解压暂时可以不用如下的一条命令.
tar xzvf output.tar.gz && rm output.tar.gz


