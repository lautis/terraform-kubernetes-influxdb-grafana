# Terraform Kubernetes example with InfluxDB and Grafana

Terraform scripts to set up a Kubernetes cluster on DigitalOcen and deploy InfluxDB and Grafana using Helm. Should be otherwise fully functional, but does not set up DNS entries for hostnames.

The InfluxDB and Grafana setup is intended to be used with [ruuvitag-listener](https://github.com/lautis/ruuvitag-listener), but can be easily customised for other purposes.

## Dependencies

* [terraform](https://www.terraform.io)
* [helm](https://helm.sh)
* [jq](https://stedolan.github.io/jq/)

## Required variables

* `do_token`: [Access Token for DigitalOcean API](https://www.digitalocean.com/docs/api/create-personal-access-token/)
* `grafana_admin_password`: password for the admin user account on Grafana
* `grafana_host`: hostname where Grafana is accessed
* `influxb_host`: hostname where InfluxDB is accessed
* `influxdb_username`: user for InfluxDB  authentication
* `influxdb_password`: password for InfluxDB authentication
* `letsencrypt_email`: email address that is used for identification on Let's Encrypt

## Running

```
terraform init
terraform apply
```
