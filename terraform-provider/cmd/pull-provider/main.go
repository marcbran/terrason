package main

import (
	_ "embed"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclparse"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
)

func main() {
	err := run(os.Args[1])
	if err != nil {
		panic(err)
	}
}

type Provider struct {
	Name    string `json:"name"`
	Source  string `json:"source"`
	Version string `json:"version"`
	Schema  any    `json:"schema"`
}

func run(dir string) error {
	provider, err := pullProvider(dir)
	if err != nil {
		return err
	}

	if provider == nil {
		return errors.New("cannot pull provider")
	}

	err = writeJson(*provider, dir)
	if err != nil {
		return err
	}

	return nil
}

func pullProvider(dir string) (*Provider, error) {
	cmd := exec.Command("terraform", fmt.Sprintf("-chdir=%s", dir), "init")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		return nil, err
	}

	source, err := readSource(dir)
	if err != nil {
		return nil, err
	}

	version, err := readVersion(dir)
	if err != nil {
		return nil, err
	}

	schema, err := readSchema(dir)
	if err != nil {
		return nil, err
	}

	provider := Provider{
		Name:    path.Base(dir),
		Source:  source,
		Version: version,
		Schema:  schema,
	}
	return &provider, nil
}

func readSource(dir string) (string, error) {
	parser := hclparse.NewParser()
	file, diags := parser.ParseHCLFile(filepath.Join(dir, ".terraform.lock.hcl"))
	if diags.HasErrors() {
		return "", fmt.Errorf("error parsing .terraform.locl.hcl: %s", diags.Error())
	}

	content, diags := file.Body.Content(&hcl.BodySchema{
		Blocks: []hcl.BlockHeaderSchema{
			{
				Type:       "provider",
				LabelNames: []string{"Name"},
			},
		},
	})
	if diags.HasErrors() {
		return "", fmt.Errorf("error decoding .terraform.locl.hcl: %s", diags.Error())
	}
	source := content.Blocks[0].Labels[0]
	return source, nil
}

func readVersion(dir string) (string, error) {
	parser := hclparse.NewParser()
	file, diags := parser.ParseHCLFile(filepath.Join(dir, ".terraform.lock.hcl"))
	if diags.HasErrors() {
		return "", fmt.Errorf("error parsing .terraform.locl.hcl: %s", diags.Error())
	}

	content, diags := file.Body.Content(&hcl.BodySchema{
		Blocks: []hcl.BlockHeaderSchema{
			{
				Type:       "provider",
				LabelNames: []string{"Name"},
			},
		},
	})
	if diags.HasErrors() {
		return "", fmt.Errorf("error decoding .terraform.locl.hcl: %s", diags.Error())
	}
	partialContent, _, diags := content.Blocks[0].Body.PartialContent(&hcl.BodySchema{
		Attributes: []hcl.AttributeSchema{
			{
				Name: "version",
			},
		},
	})
	if diags.HasErrors() {
		return "", fmt.Errorf("error getting attributes from .terraform.locl.hcl: %s", diags.Error())
	}
	value, diags := partialContent.Attributes["version"].Expr.Value(nil)
	version := value.AsString()
	return version, nil
}

func readSchema(dir string) (any, error) {
	var builder strings.Builder
	cmd := exec.Command("terraform", fmt.Sprintf("-chdir=%s", dir), "providers", "schema", "-json")
	cmd.Stdout = &builder
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		return nil, err
	}
	providerSchema := builder.String()

	var data any
	err = json.Unmarshal([]byte(providerSchema), &data)
	if err != nil {
		return nil, err
	}
	return data, nil
}

func writeJson(provider Provider, dir string) error {
	file, err := os.Create(filepath.Join(dir, "provider.json"))
	if err != nil {
		return err
	}
	defer file.Close()
	b, err := json.MarshalIndent(provider, "", "  ")
	if err != nil {
		return err
	}
	_, err = file.Write(b)
	if err != nil {
		return err
	}
	return nil
}
