all: lambda_ami_backups.zip lambda_ami_cleanups.zip

%.zip: %.py
	zip $@ $<

clean:
	rm *.zip
