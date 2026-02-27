//go:build example

package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestCreateSampleSVD(t *testing.T) {
	svd := createSampleSVD()
	if svd == nil || svd.General == nil {
		t.Fatal("expected sample svd with general section")
	}
	if svd.General.Imo != "9876543" {
		t.Fatalf("unexpected IMO: %s", svd.General.Imo)
	}
}

func TestMain(t *testing.T) {
	tmp := t.TempDir()
	wd, err := os.Getwd()
	if err != nil {
		t.Fatalf("getwd: %v", err)
	}
	defer func() { _ = os.Chdir(wd) }()
	if err := os.Chdir(tmp); err != nil {
		t.Fatalf("chdir: %v", err)
	}

	main()

	entries, err := os.ReadDir(tmp)
	if err != nil {
		t.Fatalf("readdir: %v", err)
	}
	found := false
	for _, entry := range entries {
		name := entry.Name()
		if strings.HasPrefix(name, "SVD_9876543_") && strings.HasSuffix(name, ".json") {
			if _, err := os.Stat(filepath.Join(tmp, name)); err == nil {
				found = true
				break
			}
		}
	}
	if !found {
		t.Fatal("expected exported json file from main")
	}
}
