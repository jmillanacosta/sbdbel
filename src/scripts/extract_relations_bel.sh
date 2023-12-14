#!/bin/bash

# Author: Javier Millan Acosta
# Description: This Bash script automates the process of retrieving the BEL (Biological Expression Language) specification
# and converting its relations to OWL (Web Ontology Language) object properties using YARRRML mapping files.
# The script uses YARRRML to convert the mapping files to RML (RDF Mapping Language) and RML Mapper
# to generate RDF triples. The resulting RDF triples are then saved in Turtle format.
# Finally, the script performs clean-up by removing temporary files.
# Date: October 19, 2023

# Step 1: Create a directory for temporary files
echo "Step 1: Creating a temporary directory: src/temp"
mkdir -p src/temp
cd src/temp

# Step 2: Download RML Mapper
echo "Step 2: Downloading RML Mapper v6.2.2"
wget -nc https://github.com/RMLio/rmlmapper-java/releases/download/v6.2.2/rmlmapper-6.2.2-r371-all.jar

# Step 3: Install YARRRML Parser
echo "Step 3: Installing YARRRML Parser (npm i @rmlio/yarrrml-parser -g)"
npm install -g @rmlio/yarrrml-parser

# Step 4: Run YARRRML to obtain RML
echo "Step 4: Running YARRRML on the YAML file to generate RML: relations.rml"
yarrrml-parser -i ../mapping/sbdbel_relations_mapping.yml > relations.rml

# Step 5: Download BEL specification and convert to JSON
echo "Step 5: Retrieving BEL v2.1.3 and converting it to JSON"
wget -nc https://raw.githubusercontent.com/belbio/bel_specifications/master/specifications/bel_v2_1_3.yaml

# Step 6: Install necessary libraries (yq and jq)
echo "Step 6: Installing required libraries"
sudo snap install yq
sudo snap install jq

# Step 7: Convert BEL YAML to JSON
echo "Step 7: Converting BEL YAML to JSON"
yq -j eval '.' bel_v2_1_3.yaml > data.json

# Step 8: Run RML Mapper
echo "Step 8: Running RML Mapper to generate RDF triples"
java -jar rmlmapper-6.2.2-r371-all.jar -m relations.rml -o sbdbel-relations.ttl -s turtle
cp sbdbel-relations.ttl ../ontology/sbdbel-relations.ttl

# Step 9: Check the output
echo "Step 9: Checking the generated RDF triples"
cat ../ontology/sbdbel-relations.ttl

# Step 10: Clean up the temporary directory
echo "Step 10: Cleaning up temporary files"
cd ..
rm -r temp
