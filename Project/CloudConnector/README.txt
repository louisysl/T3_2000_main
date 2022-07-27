Dieses Skript wird dazu verwendet die Installation des CitrixCloudConnectors weitgehend zu automatisieren.

Dafür müssen einzelne Parameter zur Installation konfiguriert werden.

Vor der Ausführung:
- Ordner Source anlegen (enthält Installations exe)
- Setup.xml nach Schema erstellen
- Parameter mit personalisierten Werten festlegen 

	<Setup>
		<CloudConnector>
		<CTXCloudCustomerID>AtosInforma2</CTXCloudCustomerID>
		<CTXCloudClientId>afbe8291-581f-4ff8-b295-e260e062f32e</CTXCloudClientId>
		<CTXCloudClientSecret>Si6XTYQbQjweQlyYKyQFuw==</CTXCloudClientSecret>
		<CTXCloudResourceID>e749bfbc-6096-4bd4-8712-fe318ba90974</CTXCloudResourceID>
		<Vendor>Citrix</Vendor>
		<Product>Cloud Connector</Product>
		<PackageName>cwcconnector</PackageName>
		<InstallerType>exe</InstallerType>
		</CloudConnector>
	</Setup>


Datei und Ordner Bezeichnung darf nicht abweichen!