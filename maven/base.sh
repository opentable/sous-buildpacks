#!/bin/sh

# Read the artifact name from the pom.xml
ARTIFACT_ID=$( cat pom.xml | sed '2 s/xmlns=".*"//g' | xmllint --xpath '/project/artifactId/text()' - )

# If the version if not specified then maven will use the version of the parent pom
VER=$( cat pom.xml | sed '2 s/xmlns=".*"//g' | xmllint --xpath '/project/version/text()' - 2&>1 > /dev/null || echo )
if [[ $VER == "" ]]; then
  ARTIFACT_VERSION=$( cat pom.xml | sed '2 s/xmlns=".*"//g' | xmllint --xpath '/project/parent/version/text()' - )
else
  ARTIFACT_VERSION=$( cat pom.xml | sed '2 s/xmlns=".*"//g' | xmllint --xpath '/project/version/text()' - )
fi


BUILD_ARTIFACT="$ARTIFACT_ID-$ARTIFACT_VERSION-jar-with-dependencies.jar"
