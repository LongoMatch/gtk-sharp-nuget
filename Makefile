build:
	cd cerbero && patch -p1 --forward < ../0001-Disable-GI.patch  || true
	python3 cerbero-gtk-sharp-nuget bootstrap --system no
	python3 cerbero-gtk-sharp-nuget package fluendo-gtk
