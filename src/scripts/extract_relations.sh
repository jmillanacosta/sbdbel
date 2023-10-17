#!/bin/bash

# Create a directory for temporary files
echo "Creating a temporary directory: src/temp"
mkdir -p src/temp
cd src/temp

# Download RML Mapper
echo "Downloading RML Mapper v6.2.2"
wget -nc https://github.com/RMLio/rmlmapper-java/releases/download/v6.2.2/rmlmapper-6.2.2-r371-all.jar

# Install YARRRML Parser
echo "Installing YARRRML Parser (npm i @rmlio/yarrrml-parser -g)"
npm install -g @rmlio/yarrrml-parser

# Run YARRRML to obtain RML
echo "Running YARRRML on the YAML file to generate RML: relations.rml"
yarrrml-parser -i ../mapping/sbdbel_relations_mapping.yml > relations.rml

# Download BEL specification and convert to JSON
echo "Retrieving BEL v2.1.3 and converting it to JSON"
wget -nc https://raw.githubusercontent.com/belbio/bel_specifications/master/specifications/bel_v2_1_3.yaml

# Install necessary libraries (yq and jq)
echo "... Installing required libraries"
sudo snap install yq
sudo snap install jq

# Convert BEL YAML to JSON
yq -j eval '.' bel_v2_1_3.yaml > data.json

# Run RML Mapper
echo "Running RML Mapper to generate RDF triples"
java -jar rmlmapper-6.2.2-r371-all.jar -m relations.rml -o sbdbel-relations.ttl -s turtle
cp sbdbel-relations.ttl ../ontology/sbdbel-relations.ttl

# Check output
cat ../ontology/sbdbel-relations.ttl

# Clean up the temporary directory
echo "Cleaning up temporary files"
cd ..
rm -r temp

