#!/bin/bash
# Create File version to use CI/CD
# Maintainer: Edmilson Alferes <edmilson.alferes@ibopemedia.kantar.com>


VERSION_BASE=$(cat VERSION_BASE)
BRANCH_BASE=${1}
BUILD_ID=${2}

echo "ID: ${BUILD_ID} - BRANCH: ${BRANCH_BASE}"

get_patch(){

    branch=${1}

    if [[ ${branch} =~ ^refs/heads/test/ ]]; then
        patch="-alpha.${BUILD_ID}"
    elif [[ ${branch} =~ ^refs/heads/develop ]]; then
        patch="-beta.${BUILD_ID}"
    else
        patch="-release.${BUILD_ID}"
    fi

    echo ${patch}
}

build_version(){

    patch=$(get_patch "${BRANCH_BASE}")
   
    echo "${VERSION_BASE}${patch}" > VERSION_TMP
    tr '\n' ' ' < VERSION_TMP > VERSION
    sed -i 's/ *$//g' VERSION
    mv VERSION ../
}

edit_release_note() {

    sed -i  's/^@@WILOOP@@/@@WILOOP:RTM v'${VERSION_BASE}'@@/g' template.md 
}

clean() {
    rm -rf VERSION_TMP
}

main(){

    build_version
    edit_release_note
    clean
}

main