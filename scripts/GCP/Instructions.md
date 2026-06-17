To get started, you need to create a service account in your Google Cloud Platform account and assign the required permissions.

Enable APIs for your project

Identity and Access Management (IAM) API
Resource Manager API
Compute Engine API
Cloud Billing Api
Cloudbuild Google Api
Storage Api Google Api
Storage Component Google Api
Stackdriver Monitoring Api
Cloud Quotas Api

Check that new service account was created after the Compute Engine Api was enabled on previous step.

Go to IAM, find your service account (name: Compute Engine default service account) in the list and assign these roles:
Compute Admin
add another role - Service Account User
add another role - Service Account Admin
add another role - Role Administrator
add another role - Service Account Key Admin
add another role - Project IAM Admin

Once you’ve created a Service Account, open the Service Accounts list view and find your newly created account (name: Compute Engine default service account). Then click on the button in the *Actions* column, select Manage keys and click on the button ADD KEY, select Create new key.

Select Type Key - JSON and click on the button CREATE.

After the JSON file is downloaded, copy its contents to the input field or click on the Read from file button to import the file.