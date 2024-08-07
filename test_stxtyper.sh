#!/bin/bash

if [ "$1" == "path" ]
then
    echo "Testing stxtyper command in your \$PATH"
    which stxtyper
    STXTYPER=stxtyper
else
    echo "Testing ./stxtyper"
    echo "  To test stxtyper in your path run 'test_stxtyper.sh path'"
    STXTYPER=./stxtyper
fi

# globals updated by function test_input_file
FAILURES=0
TESTS=0
TEST_TEXT=''

echo "-$TERM-"

# some color macros
if [ "$TERM" != "" ]
then
    green=`tput setaf 2`  # Set green foreground color (code 2)
    red=`tput setaf 1`    # Set red foreground color (code 1)
    reset=`tput sgr0`     # Reset color to default
else
    green='' # no colors
    red=''
    reset=''
fi

function test_input_file {
    local test_base="$1"
    local options="$2"

    TESTS=$(( $TESTS + 1 ))

    if ! $STXTYPER $options -n "test/$test_base.fa" > "test/$test_base.got"
    then
        echo "${red}not ok: $STXTYPER returned a non-zero exit value indicating a failure of the software${reset}"
        echo "#  $STXTYPER $options -n test/$test_base.fa > test/$test_base.got"
        TEST_TEXT="$TEST_TEXT"$'\n'"Failed $test_base"
        return 1
    else
        if ! diff -q "test/$test_base.expected" "test/$test_base.got"
        then
            echo "${red}not ok: $STXTYPER returned output different from expected${reset}"
            echo "#  $STXTYPER $options -n test/$test_base.fa > test/$test_base.got"
            echo "# diff test/$test_base.expected test/$test_base.got"
            diff "test/$test_base.expected" "test/$test_base.got"
            echo "#  To approve run:"
            echo "#     mv test/$test_base.got test/$test_base.expected "
            TEST_TEXT="$TEST_TEXT"$'\n'"Failed $test_base"
            return 1
        else
            echo "${green}ok:${reset} test/$test_base.fa"
            return 0
        fi
    fi
}


test_input_file 'basic' '--nucleotide_output test/basic.nuc_out.got'
FAILURES=$(( $? + $FAILURES ))
# test --nucleotide_output option
TESTS=$(( $TESTS + 1 ))
if ! diff -q "test/basic.nuc_out.expected" "test/basic.nuc_out.got"
then
    echo "${red}not ok: $STXTYPER returned --nucleotide_output file different from expected${reset}"
    echo "#  $STXTYPER --nucleotide_output test/basic.nuc_out.got -n test/basic.fa > test/basic.got"
    echo "# diff test/basic.nuc_out.expected test/basic.nuc_out.got"
    diff "test/basic.nuc_out.expected" "test/basic.nuc_out.got"
    echo "#  To approve run:"
    echo "#     mv test/basic.nuc_out.got test/basic.nuc_out.expected "
    TEST_TEXT="$TEST_TEXT"$'\n'"Failed basic --nucleotide_output test"
    FAILURES=$(( $FAILURES + 1 ))
else 
    echo "${green}ok:${reset} --nucleotide_output test/basic.nuc_out.got options worked"
fi

test_input_file 'synthetics'
FAILURES=$(( $? + $FAILURES ))

test_input_file 'virulence_ecoli'
FAILURES=$(( $? + $FAILURES ))

test_input_file 'cases'
FAILURES=$(( $? + $FAILURES ))

test_input_file 'amrfinder_integration' '--amrfinder'
FAILURES=$(( $? + $FAILURES ))

test_input_file 'amrfinder_integration2' '--amrfinder --print_node' 
FAILURES=$(( $? + $FAILURES ))

echo "Done."
echo "$TEST_TEXT"
echo ""
if [ "$FAILURES" -gt 0 ]
then
    PASSED=$(( $TESTS - $FAILURES ))
    echo "${red}not ok overall: $FAILURES out of $TESTS stxtyper tests failed${reset}"
    exit 1
else
    echo "${green}ok: all $TESTS stxtyper tests passed${reset}"
fi
