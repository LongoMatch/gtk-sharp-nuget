<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>Fluendo.GTK.{platform}</id>
    <version>{version}</version>
    <title>Fluendo.GTK native libraries for {platform}</title>
    <authors>Fluendo</authors>
    <owners>Fluendo</owners>
    <description>GTK+ native libraries and dependencies.</description>
    <summary>GTK+ native libraries and dependencies</summary>
    <tags>native graphics linux windows macos cross-platform</tags>
    <dependencies>
      <dependency id="Fluendo.GTK" version="{version}" />
    </dependencies>
  </metadata>
   <files>
    <file target="build/" src="*" />
{files}
  </files>
</package>
