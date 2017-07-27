all: lambdaAMIBackups.zip lambdaAMICleanup.zip

%.zip: %.py
	zip $@ $<

clean:
	rm *.zip
