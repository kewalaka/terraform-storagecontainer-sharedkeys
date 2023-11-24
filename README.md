# Storage Account container example

This illustrates two different ways to create storage containers when shared key authorisation is disabled.

There are two [examples](./examples), the azapi version works, the azurerm version does not.

Shared Key authorisation is disabled by default in the storage account module as per [Well-Architected Framework (WAF) guidance](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/storage-accounts/security#configuration-recommendations), quoting this guidance:

> Avoid and prevent using Shared Key authorization to access storage accounts.

The module used in this example is written in the style of [AVM](https://aka.ms/AVM), which requires alignment to WAF principles.

See [this issue](https://github.com/kewalaka/terraform-azurerm-avm-res-storage-storageaccount/issues/4#issuecomment-1826101631) for more background info.

If the use of shared keys is required or desirable, this behaviour can be overridden by setting ```shared_access_key_enabled = true``` on the module inputs, noting this reverses the recommended default.

## AzureRM example

This is expected to fail, with the following output:

```text
azurerm_storage_container.this: Creating...
╷
│ Error: containers.Client#GetProperties: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailure" Message="This request is not authorized to perform this operation.\nRequestId:d713025d-201e-0021-6829-1fce5f000000\nTime:2023-11-24T22:56:18.1712932Z"
│ 
│   with azurerm_storage_container.this,
│   on main.tf line 40, in resource "azurerm_storage_container" "this":
│   40: resource "azurerm_storage_container" "this" {
│ 
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
```

## AZAPI example

This will succeed.

## Example E2E test

There is a [github action](.github/workflows/e2e.yml) in this repository which tests this behaviour, check this [example run](https://github.com/kewalaka/terraform-storagecontainer-sharedkeys/actions/runs/6985458140) to see the result.
