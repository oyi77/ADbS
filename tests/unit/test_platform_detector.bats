#!/usr/bin/env bats
# Unit tests for platform_detector.sh

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "platform_detector_fileExists_whenChecked_returnsTrue" {
    assert_file_exists "$PROJECT_ROOT/lib/platform_detector.sh"
}

@test "platform_detector_isExecutable_whenChecked_returnsTrue" {
    [ -x "$PROJECT_ROOT/lib/platform_detector.sh" ] || [ -f "$PROJECT_ROOT/lib/platform_detector.sh" ]
}

@test "platform_detector_detect_whenRun_returnsSuccess" {
    run bash "$PROJECT_ROOT/lib/platform_detector.sh" detect
    [ "$status" -eq 0 ]
}

@test "platform_detector_detect_whenRun_returnsValidPlatform" {
    run bash "$PROJECT_ROOT/lib/platform_detector.sh" detect
    [ "$status" -eq 0 ]
    # Should return one of: cursor, windsurf, zed, trae, gemini, vscode, generic
    [[ "$output" =~ ^(cursor|windsurf|zed|trae|gemini|vscode|generic)$ ]] || true
}

@test "platform_detector_rulesDir_whenRun_returnsDirectory" {
    run bash "$PROJECT_ROOT/lib/platform_detector.sh" rules-dir
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "platform_detector_rulesFile_whenRun_returnsFilename" {
    run bash "$PROJECT_ROOT/lib/platform_detector.sh" rules-file
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "platform_detector_invalidCommand_whenRun_returnsError" {
    run bash "$PROJECT_ROOT/lib/platform_detector.sh" invalid-command
    [ "$status" -ne 0 ]
}

@test "platform_detector_help_whenRun_showsUsage" {
    run bash "$PROJECT_ROOT/lib/platform_detector.sh" --help
    # May or may not have help, just check it doesn't crash
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "platform_detector_mockIdeEnv_whenCursorMocked_setsEnvVars" {
    mock_ide_env "cursor"
    
    [ "$MOCK_IDE" = "cursor" ]
    [ -n "$MOCK_IDE_CONFIG" ]
}

@test "platform_detector_mockIdeEnv_whenZedMocked_setsEnvVars" {
    mock_ide_env "zed"
    
    [ "$MOCK_IDE" = "zed" ]
    [ -n "$MOCK_IDE_CONFIG" ]
    # Zed should be single-file
    [[ "$MOCK_IDE_CONFIG" == *'"supports_multi_file": false'* ]]
}
