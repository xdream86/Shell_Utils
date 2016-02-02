#! /bin/bash

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

    find "$j"  -iname '*.car'  -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/"$j".car
    find "$j"  -iname '*.png'  -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/png
    find "$j"  -iname '*.wav' -or -iname '*m4a' -or -iname '*caf' -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/audio
    find "$j"  -iname '*.ttf' -or -iname '*otf' -print0 | xargs -0 -I {} cp -n  {} iparesource/"$j"/font

    cartool iparesource/"$j"/*.car iparesource/"$j"/carpng

    # 删除所有除了iparesource目录和.目录以外的所有目录
    find . ! -iname '*.ipa' !  -iname 'iparesource' ! -iname '.' -type d -maxdepth 1 -exec rm -rf {} +
done

exit 0

