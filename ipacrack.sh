#! /bin/bash

count=`ls -1 *.ipa  2>/dev/null | wc -l`
if [ $count == 0 ]; then
    echo "not found .ipa file in current folder"
    exit -1;
fi

rm -rf iparesource
mkdir iparesource

for i in *.ipa; do
    j=${i%.ipa}
    mkdir "$j"
    unzip "$i" -d "$j"
    mkdir iparesource/"$j"
    mkdir iparesource/"$j"/png
    mkdir iparesource/"$j"/audio
    mkdir iparesource/"$j"/carpng
    mkdir iparesource/"$j"/font
    mkdir iparesource/"$j"/mp4
    mkdir iparesource/"$j"/screenshot

    find "$j"  -iname '*.car'  -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/"$j".car
    find "$j"  -iname '*.png'  -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/png
    find "$j"  \( -iname '*.wav' -or -iname '*m4a' -or -iname '*caf' \) -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/audio
    find "$j"  \( -iname '*.ttf' -or -iname '*otf' \) -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/font
    find "$j"  -iname '*.mp4'  -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/mp4

    # 抽取carpng图片 cartool:https://github.com/G-P-S/cartool
    cartool iparesource/"$j"/*.car iparesource/"$j"/carpng

    #下载screentshot图片
    appid=`/usr/libexec/PlistBuddy -c "Print :itemId" "$j/iTunesMetadata.plist"`

    curl http://itunes.apple.com/lookup?id=$appid > appinfo.json

    IFS=$'\n'; array=($(cat appinfo.json | jq '.results[0].screenshotUrls[]'))

    arraylength=${#array[@]}

    for (( i=1; i<${arraylength}+1; i++ )); do
        fileurl=${array[$i-1]}
        fileurl="${fileurl%\"}"
        fileurl="${fileurl#\"}"
        extension="${fileurl##*.}"

        wget $fileurl -O iparesource/"$j"/screenshot/$i.$extension
    done

    rm -rf "$j" appinfo.json
done

exit 0

