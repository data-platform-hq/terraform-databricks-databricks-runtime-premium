## [2.0.5](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v2.0.4...v2.0.5) (2023-05-23)


### Bug Fixes

* secrets scope key vault ([7b9dd79](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/7b9dd79ea3172a48461cc23e1a61618d290148c0))

## [2.0.4](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v2.0.3...v2.0.4) (2023-05-23)


### Bug Fixes

* key vault secret scope fixed ([75a5444](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/75a5444522f66139bf34f504e33d76605cb03660))
* removed whitespace ([dab2984](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/dab2984b3a369071e85e2e122fbdabcfac31f191))
* whitespace ([021b5bd](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/021b5bde443e38df9ea3cce747dd3508920d9432))

## [2.0.3](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v2.0.2...v2.0.3) (2023-05-23)


### Bug Fixes

* added databricks_secret_acl ([2db5b75](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/2db5b75dd728c9d47701d5b5fcbca06cee649bae))
* changed scope name ([54b07b8](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/54b07b820bb3b970b48cbd01a32a8e9aebda1cd6))

## [2.0.2](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v2.0.1...v2.0.2) (2023-05-20)


### Bug Fixes

* updated condition for resource permissions ([52abfd1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/52abfd19cb858dc40170d39e04c8bb4303d2fc7f))

## [2.0.1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v2.0.0...v2.0.1) (2023-05-20)


### Bug Fixes

* added cluster outputs ([0264305](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/0264305b5e9093aea3899d8f6f9472c53167e440))

# [2.0.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.9.1...v2.0.0) (2023-05-19)


### Bug Fixes

* updated variables; and condition ([1285f91](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/1285f91b0d29a7f151e37332683424f421a5e117))


### Features

* delete unity catalog ([9d4b70a](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/9d4b70ad24a45ccda642318be7d641f3126bc7a7))
* delete unity.tf ([94cf091](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/94cf091bf6a3a5ece1e380f7e570f76ef2d914d2))


### BREAKING CHANGES

* unity catalog in individual module

## [1.9.1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.9.0...v1.9.1) (2023-05-19)


### Bug Fixes

* updated varialbes ([280425b](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/280425b29f21fcd45b433a011c61499c20704a93))

# [1.9.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.8.0...v1.9.0) (2023-05-15)


### Bug Fixes

* terraform fmt ([dd85f6b](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/dd85f6ba52133fd50deb766f3ab90ebc15868b7d))


### Features

* Azure-backed Databricks Secret scope ([4c1f7d4](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/4c1f7d472000de44bf7a33a4a0193be42e899f98))

# [1.8.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.7.2...v1.8.0) (2023-04-20)


### Bug Fixes

* changed default value, var name, formatting ([e1ff063](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/e1ff0630d06a6e5a054ab66a191dc158d8edbdc8))
* fixed formatting ([430e3f4](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/430e3f469c336202eb53d6266f524567c61c1174))


### Features

* added cluster name option to use during mount ([41d0f5f](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/41d0f5fc5a10861c998666022fa514c8cc9f0e56))
* added credential passthrough ([4cfee37](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/4cfee370f3384d415c90468f8023db3f1aada641))

## [1.7.2](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.7.1...v1.7.2) (2023-04-13)


### Bug Fixes

* added output which provides name and id for clusters ([0fa4e44](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/0fa4e4476a9b5f5d8411c08595218fc3619d3478))

## [1.7.1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.7.0...v1.7.1) (2023-04-11)


### Bug Fixes

* create variable pat_token_lifetime_seconds ([fee1b05](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/fee1b055d1ab99e85e277eccc462996bdac3780c))
* move cluster policy to cluster tf ([90194ac](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/90194ac72b570f3f2dcadbeb8daf9a1893f662d5))
* remove commited lines ([7789718](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/77897183750b42fc6ab8290f2bb1ac2878d593d1))
* updated condition for secret scope ([8f4cf89](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/8f4cf8952d794d55c0329a3e7f38686e977e630f))

# [1.7.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.6.1...v1.7.0) (2023-04-09)


### Bug Fixes

* add end line ([cd5a9aa](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/cd5a9aaa37299bb3684f7e26ac7bcaa51b3b2242))
* changed uniti cluste ([9a72e4e](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/9a72e4e30211d267dbcb2357bc2efa6a95de363b))
* delete unuses variable ([d1358b3](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/d1358b336ab0ed9120b3ac34fb5851b92748d8bc))


### Features

* redactor ([3e3477e](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/3e3477efe79b8efbec8bd0537679e37124a65a13))
* refactoring ([3122e9f](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/3122e9fca70e0d984250f088ce04d62482216908))

## [1.6.1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.6.0...v1.6.1) (2023-03-28)


### Bug Fixes

* update unity cluster condition ([b99e77a](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/b99e77aa1963551dce8e8500d5627902d05cd1b9))

# [1.6.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.5.2...v1.6.0) (2023-03-24)


### Bug Fixes

* add group permission index ([dc6df2f](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/dc6df2f724a9ac203a5be407db09d762517ab34e))
* changed readmi ([01f9431](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/01f9431e87adc050a7fa5d95a228abfbaf2b5f1a))


### Features

* added few different examples for module usage ([d9ead71](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/d9ead71748644fd66e84f04a60ee8e8d3588ef4c))
* uniti claster ([49a0afa](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/49a0afaad87db263b2deff4f96219b9cb23eaf04))

## [1.5.2](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.5.1...v1.5.2) (2023-03-16)


### Bug Fixes

* remove precondition ([b7fce2d](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/b7fce2df91ab68a60a6263a2a41856b994109e19))

## [1.5.1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.5.0...v1.5.1) (2023-03-10)


### Bug Fixes

* entitlements validation and creation fix ([3b84508](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/3b84508088f32f3872b23b4fc7b48dca31d21ac4))

# [1.5.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.4.2...v1.5.0) (2023-03-06)


### Bug Fixes

* updated serverless condition ([171f881](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/171f88131130dfffacf7e35ac64cd9b91bc6d40e))


### Features

* clean-up ([26ea36d](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/26ea36dd33c53db8111cf8fab4ba5e4fba04380b))
* sql refactor, serverless feature, consistent permissions ([fafee0c](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/fafee0c6a25ce683fd2bf8257fb0589a620e8d9c))

## [1.4.2](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.4.1...v1.4.2) (2023-02-25)


### Bug Fixes

* fmt ([a0a6447](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/a0a644770ff15bd1737630974392c66ca2eb2114))
* updated logic for databricks_permissions.default_cluster ([b85744f](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/b85744f5949174a12db367f0fc815d040e958050))

## [1.4.1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.4.0...v1.4.1) (2023-02-14)


### Bug Fixes

* fixed for loop and condition for cluster permissions ([6bc4d82](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/6bc4d8241541e315c289a85b8a3726ded41b688f))

# [1.4.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.3.0...v1.4.0) (2023-02-10)


### Features

* secret scope acls ([c8a3910](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/c8a3910ea1be835b331c350c5e385712f08abed1))

# [1.3.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.2.0...v1.3.0) (2023-02-06)


### Bug Fixes

* changed readme.md ([3f68e8e](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/3f68e8e8eaff22d7b07bde663811441b5bcd139c))
* fmt ([dbbce0e](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/dbbce0e0e56aeb25d566e8935e9a56d06a09202a))
* fmt ([560fb75](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/560fb753281a97e658830a8c05c3436a6e4b4291))


### Features

* cluster and clsuter policy permission assignments ([3a65ada](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/3a65ada53382675f3bd90ce0fec0b62308301834))

# [1.2.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.1.0...v1.2.0) (2023-01-30)


### Bug Fixes

* azurerm provider; removed sku var ([4cf3af5](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/4cf3af5122e5b7dc391a0cb797961691d663578b))
* lint ([85f2c75](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/85f2c75f0245ae69c1147e3c9741cd5bdd6e894f))
* removed version constraint on azurerm provider ([8738ea8](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/8738ea86f8009164459730ebde21e26c7690c8ed))


### Features

* unity catalog ([58ffa3c](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/58ffa3c93691b1de841e4f321f668410dfaee465))

# [1.1.0](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/compare/v1.0.0...v1.1.0) (2023-01-20)


### Bug Fixes

* replaced permission_assignment with group_member ([27d38e1](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/27d38e125ec98bf8e40560dd12a37a23bfca3cec))


### Features

* fix release ([35bd98d](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/35bd98d5849b1fc716e026b14e3b474a56628c02))
* iam refactor; entitlements ([6308195](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/63081953e2c41b24bfedda2a2985d67d60dd3022))


# 1.0.0 (2022-10-21)


### Bug Fixes

* fixed lint ([561d5f5](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/561d5f5abf08b81fa39c37f57c9d7d530b076d25))


### Features

* add module ([31496df](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/31496dfda96cbbe4ce68105d009b4de3fed7cc61))
* added README.md ([dc2b2d6](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/commit/dc2b2d6cb13f3a40c996a50557a17913a922467e))
