#!/usr/bin/env bats

load ../test_helper.bash

DEBBUILD_DIR="$(resolve_script debbuild)"

@test "debbuild/DEBIAN/control exists" {
    [[ -f "$DEBBUILD_DIR/DEBIAN/control" ]]
}

@test "debbuild/DEBIAN/control has Package field" {
    grep -q "^Package: termux-dotfiles$" "$DEBBUILD_DIR/DEBIAN/control"
}

@test "debbuild/DEBIAN/control has Version field with __VERSION__ placeholder" {
    grep -q "^Version: __VERSION__$" "$DEBBUILD_DIR/DEBIAN/control"
}

@test "debbuild/DEBIAN/control has Architecture field" {
    grep -q "^Architecture: all$" "$DEBBUILD_DIR/DEBIAN/control"
}

@test "debbuild/DEBIAN/control has Maintainer field" {
    grep -q "^Maintainer: ipproyectossoluciones@gmail.com$" "$DEBBUILD_DIR/DEBIAN/control"
}

@test "debbuild/DEBIAN/control has Depends field" {
    grep -q "^Depends:" "$DEBBUILD_DIR/DEBIAN/control"
}

@test "debbuild/DEBIAN/control has Section field" {
    grep -q "^Section: utilities$" "$DEBBUILD_DIR/DEBIAN/control"
}

@test "debbuild/DEBIAN/postinst exists and is executable" {
    [[ -f "$DEBBUILD_DIR/DEBIAN/postinst" ]]
    [[ -x "$DEBBUILD_DIR/DEBIAN/postinst" ]]
}

@test "debbuild/DEBIAN/postinst has correct shebang" {
    head -1 "$DEBBUILD_DIR/DEBIAN/postinst" | grep -q "^#!/data/data/com.termux/files/usr/bin/bash$"
}

@test "debbuild/DEBIAN/postinst creates symlinks" {
    grep -q 'ln -sf' "$DEBBUILD_DIR/DEBIAN/postinst"
}

@test "debbuild/DEBIAN/prerm exists and is executable" {
    [[ -f "$DEBBUILD_DIR/DEBIAN/prerm" ]]
    [[ -x "$DEBBUILD_DIR/DEBIAN/prerm" ]]
}

@test "debbuild/DEBIAN/prerm has correct shebang" {
    head -1 "$DEBBUILD_DIR/DEBIAN/prerm" | grep -q "^#!/data/data/com.termux/files/usr/bin/bash$"
}

@test "debbuild/DEBIAN/prerm removes symlinks" {
    grep -q 'rm -f' "$DEBBUILD_DIR/DEBIAN/prerm"
}

@test "debbuild/data/data/com.termux/files/usr/bin/ai exists" {
    [[ -f "$DEBBUILD_DIR/data/data/com.termux/files/usr/bin/ai" ]]
}

@test "debbuild/data/data/com.termux/files/usr/bin/ai is executable" {
    [[ -x "$DEBBUILD_DIR/data/data/com.termux/files/usr/bin/ai" ]]
}

@test "debbuild/data/data/com.termux/files/usr/bin/ai has correct shebang" {
    head -1 "$DEBBUILD_DIR/data/data/com.termux/files/usr/bin/ai" | grep -q "^#!/data/data/com.termux/files/usr/bin/bash$"
}

@test "debbuild/data/data/com.termux/files/usr/bin/aip exists" {
    [[ -f "$DEBBUILD_DIR/data/data/com.termux/files/usr/bin/aip" ]]
}

@test "debbuild/data/data/com.termux/files/usr/bin/aip is executable" {
    [[ -x "$DEBBUILD_DIR/data/data/com.termux/files/usr/bin/aip" ]]
}

@test "debbuild/data/data/com.termux/files/usr/etc/profile.d/termux-dotfiles.sh exists" {
    [[ -f "$DEBBUILD_DIR/data/data/com.termux/files/usr/etc/profile.d/termux-dotfiles.sh" ]]
}

@test "debbuild/data/data/com.termux/files/usr/share/termux-dotfiles/ directory exists" {
    [[ -d "$DEBBUILD_DIR/data/data/com.termux/files/usr/share/termux-dotfiles" ]]
}