#!/bin/bash
# Library API write functions testing script
#
# Version: 20161105

EXIT_SUCCESS=0;
EXIT_FAILURE=1;
EXIT_IGNORE=77;

TEST_PREFIX=`dirname ${PWD}`;
TEST_PREFIX=`basename ${TEST_PREFIX} | sed 's/^lib\([^-]*\)/\1/'`;

TEST_PROFILE="lib${TEST_PREFIX}";
TEST_FUNCTIONS="handle_write pool_write";
OPTION_SETS="";

TEST_TOOL_DIRECTORY=".";

test_api_write_function()
{ 
	local TEST_FUNCTION=$1;
	shift 1;
	local ARGUMENTS=$@;

	local TEST_DESCRIPTION="Testing API write function: lib${TEST_PREFIX}_${TEST_FUNCTION}";
	local TEST_EXECUTABLE="${TEST_TOOL_DIRECTORY}/${TEST_PREFIX}_test_${TEST_FUNCTION}";

	if ! test -x "${TEST_EXECUTABLE}";
	then
		TEST_EXECUTABLE="${TEST_EXECUTABLE}.exe";
	fi

	TMPDIR="tmp$$";

	rm -rf ${TMPDIR};
	mkdir ${TMPDIR};

	run_test_with_arguments "${TEST_DESCRIPTION}" "${TEST_EXECUTABLE}" "${TMPDIR}/write" ${ARGUMENTS[*]};
	local RESULT=$?;

	rm -rf ${TMPDIR};

	return ${RESULT};
}

test_write()
{
	local TEST_FUNCTION=$1;

	test_api_write_function "${TEST_FUNCTION}" 0;
	RESULT=$?;

	if test ${RESULT} -ne ${EXIT_SUCCESS};
	then
		return ${RESULT};
	fi

	test_api_write_function "${TEST_FUNCTION}" 1000;
	RESULT=$?;

	return ${RESULT};
}

if ! test -z ${SKIP_LIBRARY_TESTS};
then
	exit ${EXIT_IGNORE};
fi

TEST_RUNNER="tests/test_runner.sh";

if ! test -f "${TEST_RUNNER}";
then
	TEST_RUNNER="./test_runner.sh";
fi

if ! test -f "${TEST_RUNNER}";
then
	echo "Missing test runner: ${TEST_RUNNER}";

	exit ${EXIT_FAILURE};
fi

source ${TEST_RUNNER};

for TEST_FUNCTION in ${TEST_FUNCTIONS};
do
	test_write "${TEST_FUNCTION}";
	RESULT=$?;

	if test ${RESULT} -ne ${EXIT_SUCCESS};
	then
		break;
	fi
done

exit ${RESULT};

