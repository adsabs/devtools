#!/bin/bash

# generate a set of column files with data for the specified bibcodes
# it includes all the other bibcodes needed to compute accurate metrics on the input bibcodes
# the directory structure of the output directory matches the structure of the input data
# on adswhy, takes just under two minutes for an input file with 500 bibcodes

if [ "$#" -ne 3 ]; then
    echo 'create a set of column files containing data for the specified bibcodes'
    echo 'usage: createTestColumnFiles.sh fileOfTestBibcodes pathToInputColumnFiles pathToOutputDirectory'
    echo 'e.g.: createTestColumnFiles.sh bibcodesTestSample.10 /proj/ads/abstracts/current data/'
    exit 1
fi

inputBibcodeFile=$1
inputDir=$2
outputDir=$3

mkdir -p $outputDir/alsoread_bib
mkdir -p $outputDir/citation
mkdir -p $outputDir/facet_authors
mkdir -p $outputDir/grants
mkdir -p $outputDir/reads
mkdir -p $outputDir/refereed
mkdir -p $outputDir/reference
mkdir -p $outputDir/relevance
mkdir -p $outputDir/simbad


grep -F -f $inputBibcodeFile $inputDir/bibcodes.list.can > $outputDir/bibcodes.list.can.tmp
# also pick up papers that cite the given bibcodes so metrics can be computed
grep -F -f $inputBibcodeFile $inputDir/reference/all.links | cut -f 1 >> $outputDir/bibcodes.list.can.tmp
sort --unique $outputDir/bibcodes.list.can.tmp > $outputDir/bibcodes.list.can
rm $outputDir/bibcodes.list.can.tmp

grep -F -f $outputDir/bibcodes.list.can $inputDir/alsoread_bib/all.links > $outputDir/alsoread_bib/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/citation/all.links > $outputDir/citation/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/facet_authors/all.links > $outputDir/facet_authors/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/grants/all.links > $outputDir/grants/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/reads/all.links > $outputDir/reads/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/reads/downloads.links > $outputDir/reads/downloads.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/refereed/all.links > $outputDir/refereed/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/reference/all.links > $outputDir/reference/all.links
grep -F -f $outputDir/bibcodes.list.can $inputDir/relevance/docmetrics.tab > $outputDir/relevance/docmetrics.tab
grep -F -f $outputDir/bibcodes.list.can $inputDir/simbad/simbad_objects.tab > $outputDir/simbad/simbad_objects.tab
