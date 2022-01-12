#!/bin/bash
ACCOUNT_URL=$(eval echo "\$$PARAM_ACCOUNT_URL")
TAG=$(eval echo "$PARAM_TAG")
SKIP_WHEN_TAGS_EXIST=$(eval echo "$PARAM_SKIP_WHEN_TAGS_EXIST")
REPO=$(eval echo "$PARAM_REPO")
EXTRA_BUILD_ARGS=$(eval echo "$PARAM_EXTRA_BUILD_ARGS")
PATH=$(eval echo "$PARAM_PATH")
DOCKERFILE=$(eval echo "$PARAM_PATH")
PROFILE_NAME=$(eval echo "$PARAM_PROFILE_NAME")
ACCOUNT_ID=$(eval echo "\$$PARAM_ACCOUNT_ID")

echo "$ACCOUNT_URL" >> test.txt
echo "$TAG" >> test.txt
echo "$SKIP_WHEN_TAGS_EXIST" >> test.txt
echo "$REPO" >> test.txt
echo "$EXTRA_BUILD_ARGS">> test.txt
echo "$PATH" >> test.txt
echo "$DOCKERFILE"  >> test.txt
echo "$PROFILE_NAME" >> test.txt
echo "$ACCOUNT_ID" >> test.txt
# registry_id=$(echo "$ACCOUNT_URL" | sed "s;\..*;;g")
number_of_tags_in_ecr=0
# echo "Registry ID: $registry_id" >> test.txt
docker_tag_args=""
IFS="," read -ra DOCKER_TAGS <<< "$TAG"
for tag in "${DOCKER_TAGS[@]}"; do
    echo "${DOCKER_TAGS[@]}" >>test.txt
    echo "$TAG" >> test.txt
    if [ "$SKIP_WHEN_TAGS_EXIST" = "true" ]; then
    docker_tag_exists_in_ecr=$(aws ecr describe-images --profile "$PROFILE_NAME" --registry-id "$ACCOUNT_ID" --repository-name "$REPO" --query "contains(imageDetails[].imageTags[], '$tag')")
    if [ "$docker_tag_exists_in_ecr" = "true" ]; then
        docker pull "${ACCOUNT_URL}"/"$REPO":$tag
        let "number_of_tags_in_ecr+=1"
    fi
    fi
    docker_tag_args="$docker_tag_args -t "${ACCOUNT_URL}/$REPO":$tag"
    echo "Docker tag args: $docker_tag_args" >> test.txt
done
if [ "$SKIP_WHEN_TAGS_EXIST" = "false" ] || [ "$SKIP_WHEN_TAGS_EXIST" = "true" -a $number_of_tags_in_ecr -lt ${#DOCKER_TAGS[@]} ]; then
    # docker build \
    
        if [ -n "$EXTRA_BUILD_ARGS" ]; then
            echo "It gets to this if block" >> test.txt
            set -- "$@" "$EXTRA_BUILD_ARGS"
        fi
    set -- "$@" -f "$PATH"/"$DOCKERFILE" "$docker_tag_args" "$PATH"
    echo "$@" >> test.txt
    docker build "$@"
fi
