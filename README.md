<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![README Header][readme_header_img]][readme_header_link]

[![Cloud Posse][logo]](https://cpco.io/homepage)

# terraform-aws-ec2-ami-backup [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-ec2-ami-backup.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-ec2-ami-backup) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-ec2-ami-backup.svg)](https://travis-ci.org/cloudposse/terraform-aws-ec2-ami-backup/releases) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


This repo contains a terraform module that creates two lambda functions
that will create AMI automatically at regular intervals. It is based on
the code at
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups/> and
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups-2/>.


---

This project is part of our comprehensive ["SweetOps"](https://cpco.io/sweetops) approach towards DevOps. 
[<img align="right" title="Share via Email" src="https://docs.cloudposse.com/images/ionicons/ios-email-outline-2.0.1-16x16-999999.svg"/>][share_email]
[<img align="right" title="Share on Google+" src="https://docs.cloudposse.com/images/ionicons/social-googleplus-outline-2.0.1-16x16-999999.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" src="https://docs.cloudposse.com/images/ionicons/social-facebook-outline-2.0.1-16x16-999999.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" src="https://docs.cloudposse.com/images/ionicons/social-reddit-outline-2.0.1-16x16-999999.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" src="https://docs.cloudposse.com/images/ionicons/social-linkedin-outline-2.0.1-16x16-999999.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" src="https://docs.cloudposse.com/images/ionicons/social-twitter-outline-2.0.1-16x16-999999.svg" />][share_twitter]


[![Terraform Open Source Modules](https://docs.cloudposse.com/images/terraform-open-source-modules.svg)][terraform_modules]





It's 100% Open Source and licensed under the [MIT](LICENSE).





We literally have [*hundreds of terraform modules*][terraform_modules] that are Open Source and well-maintained. Check them out! 







## Usage

Include this repository as a module in your existing terraform code:

```hcl
module "lambda_ami_backup" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-ami-backup.git?ref=tags/0.3.2"

  name           = "${var.name}"
  stage          = "${var.stage}"
  namespace      = "${var.namespace}"
  region         = "${var.region}"
  ami_owner      = "${var.ami_owner}"
  instance_id    = "${var.instance_id}"
  retention_days = "14"
}
```




## Examples

Example on excluding some of attached EBS volumes:

```hcl
module "lambda_ami_backup" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-ami-backup.git?ref=tags/0.3.2"

  name           = "${var.name}"
  stage          = "${var.stage}"
  namespace      = "${var.namespace}"
  region         = "${var.region}"
  ami_owner      = "${var.ami_owner}"
  instance_id    = "${var.instance_id}"
  retention_days = "14"

  block_device_mappings = [
    { "DeviceName" = "/dev/xvdf", "NoDevice" = "" },
    { "DeviceName" = "/dev/xvdg", "NoDevice" = "" },
  ]
}
```



## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami_owner | AWS Account ID which is used as a filter for AMI list (e.g. `123456789012`) | string | `` | no |
| backup_schedule | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | string | `cron(00 19 * * ? *)` | no |
| block_device_mappings | List of block device mappings to be included/excluded from created AMIs. With default value of [], AMIs will include all attached EBS volumes | list | `<list>` | no |
| cleanup_schedule | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | string | `cron(05 19 * * ? *)` | no |
| instance_id | AWS Instance ID which is used for creating the AMI image (e.g. `id-123456789012`) | string | - | yes |
| name | Name  (e.g. `bastion` or `db`) | string | `` | no |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `` | no |
| reboot | Reboot the machine as part of the snapshot process | string | `false` | no |
| region | AWS Region where module should operate (e.g. `us-east-1`) | string | `` | no |
| retention_days | Is the number of days you want to keep the backups for (e.g. `14`) | string | `14` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |




## Share the Love 

Like this project? Please give it a ★ on [our GitHub](https://github.com/cloudposse/terraform-aws-ec2-ami-backup)! (it helps us **a lot**) 

Are you using this project or any of our other projects? Consider [leaving a testimonial][testimonial]. =)


## Related Projects

Check out these related projects.

- [terraform-aws-ec2-ami-snapshot](https://github.com/cloudposse/terraform-aws-ec2-ami-snapshot) - Terraform module to easily generate AMI snapshots to create replica instances
- [terraform-aws-efs-backup](https://github.com/cloudposse/terraform-aws-efs-backup) - Terraform module designed to easily backup EFS filesystems to S3 using DataPipeline




## References

For additional context, refer to some of these links. 

- [Terraform config for automatic EBS snapshots](https://github.com/chef/lambda_ebs_snapshot) - This repo contains a terraform configuration that creates two lambda functions that will take automatic EBS snapshots at regular intervals.


## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-ec2-ami-backup/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)][email]

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll [develop original modules][module_development] to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 



## Terraform Module Development

Are you interested in custom Terraform module development? Submit your inquiry using [our form][module_development] today and we'll get back to you ASAP.


## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Newsletter

Signup for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover. 

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-ec2-ami-backup/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!



## Copyrights

Copyright © 2016-2018 [Chef Software, Inc](https://www.chef.io/)








## License 

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Source: <https://opensource.org/licenses/MIT>






## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.  

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

|  [![Sergey Vasilyev][s2504s_avatar]][s2504s_homepage]<br/>[Sergey Vasilyev][s2504s_homepage] | [![Mark Harrison][mivok_avatar]][mivok_homepage]<br/>[Mark Harrison][mivok_homepage] | [![Vladimir][SweetOps_avatar]][SweetOps_homepage]<br/>[Vladimir][SweetOps_homepage] | [![Tron Thongsringklee][thanandorn_avatar]][thanandorn_homepage]<br/>[Tron Thongsringklee][thanandorn_homepage] | [![Raymond Butcher][raymondbutcher_avatar]][raymondbutcher_homepage]<br/>[Raymond Butcher][raymondbutcher_homepage] | [![Anthony DeMartini][ademartini_avatar]][ademartini_homepage]<br/>[Anthony DeMartini][ademartini_homepage] | [![Konstantin B][comeanother_avatar]][comeanother_homepage]<br/>[Konstantin B][comeanother_homepage] | [![Seth Chisamore][schisamo_avatar]][schisamo_homepage]<br/>[Seth Chisamore][schisamo_homepage] |
|---|---|---|---|---|---|---|---|

  [s2504s_homepage]: https://github.com/s2504s
  [s2504s_avatar]: https://github.com/s2504s.png?size=150
  [mivok_homepage]: https://github.com/mivok
  [mivok_avatar]: https://github.com/mivok.png?size=150
  [SweetOps_homepage]: https://github.com/SweetOps
  [SweetOps_avatar]: https://github.com/SweetOps.png?size=150
  [thanandorn_homepage]: https://github.com/thanandorn
  [thanandorn_avatar]: https://github.com/thanandorn.png?size=150
  [raymondbutcher_homepage]: https://github.com/raymondbutcher
  [raymondbutcher_avatar]: https://github.com/raymondbutcher.png?size=150
  [ademartini_homepage]: https://github.com/ademartini
  [ademartini_avatar]: https://github.com/ademartini.png?size=150
  [comeanother_homepage]: https://github.com/comeanother
  [comeanother_avatar]: https://github.com/comeanother.png?size=150
  [schisamo_homepage]: https://github.com/schisamo
  [schisamo_avatar]: https://github.com/schisamo.png?size=150



[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs
  [website]: https://cpco.io/homepage
  [github]: https://cpco.io/github
  [jobs]: https://cpco.io/jobs
  [hire]: https://cpco.io/hire
  [slack]: https://cpco.io/slack
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://cpco.io/twitter
  [testimonial]: https://cpco.io/leave-testimonial
  [newsletter]: https://cpco.io/newsletter
  [email]: https://cpco.io/email
  [commercial_support]: https://cpco.io/commercial-support
  [we_love_open_source]: https://cpco.io/we-love-open-source
  [module_development]: https://cpco.io/module-development
  [terraform_modules]: https://cpco.io/terraform-modules
  [readme_header_img]: https://cloudposse.com/readme/header/img?repo=cloudposse/terraform-aws-ec2-ami-backup
  [readme_header_link]: https://cloudposse.com/readme/header/link?repo=cloudposse/terraform-aws-ec2-ami-backup
  [readme_footer_img]: https://cloudposse.com/readme/footer/img?repo=cloudposse/terraform-aws-ec2-ami-backup
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?repo=cloudposse/terraform-aws-ec2-ami-backup
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img?repo=cloudposse/terraform-aws-ec2-ami-backup
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?repo=cloudposse/terraform-aws-ec2-ami-backup
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-ec2-ami-backup&url=https://github.com/cloudposse/terraform-aws-ec2-ami-backup
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-ec2-ami-backup&url=https://github.com/cloudposse/terraform-aws-ec2-ami-backup
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-aws-ec2-ami-backup
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-aws-ec2-ami-backup
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-aws-ec2-ami-backup
  [share_email]: mailto:?subject=terraform-aws-ec2-ami-backup&body=https://github.com/cloudposse/terraform-aws-ec2-ami-backup
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-ec2-ami-backup?pixel&cs=github&cm=readme&an=terraform-aws-ec2-ami-backup
