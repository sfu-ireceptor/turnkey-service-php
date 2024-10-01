# Release Notes

## v4.0 (Dec 7, 2022)
Official 4.0 release. [More details about iReceptor 4.0](https://ireceptor.org/ireceptor-4).

- Key new features in production:
	- Implementation of storing Clone data and querying on /clone API endpoint
	- Implementation of storing Cell data and querying on /cell API endpoint
	- Implementation of storing Expression data and querying on /expression API endppoint
	- Add scripts to load Clone/Cell/Expression data
- Add [turnkey upgrade instructions from v3 to v4](doc/upgrading_from_v3_to_v4.md)
- Add [scripts to upgrade an existing turnkey database for v4.0](doc/updating_the_database_1.4.md)
- Rename some util scripts
- Add [Code of Conduct](CODE_OF_CONDUCT.md) and [Contributing Guidelines](CONTRIBUTING.md)
- Minor bug fixes

## v4.0-pre (Sep 9, 2022)
- Enable [customization of the home page](doc/customizing_home_page.md)

## v4.0-pre (June 13, 2022)
- Enable [customization of the /airr/v1/info entry point](doc/customizing_info_entry_point.md)

## v4.0-pre (May 19, 2022)
- Use systemd to start turnkey on boot
- Minor bug fixes

## v4.0-pre (Apr 4, 2022)
- Add clone support
- Add cell support
- Add expression support
- Add stats removal

## v4.0-pre (Dec 22, 2021)
- Use HTTPS by default (with a generated self-signed SSL certificate)
- Use web service ``turnkey-v4`` branch
- Add stats loading script
- Add clone loading script
- Add metadata update script

## v3.1 (May 10, 2021)

### Web service update
- Security update:
	- Upgrade PHP (7.2 -> 7.3.27)
	- Update PHP dependencies (via composer)
	- Disable CGI
	- Tighten some files permissions
- Enable [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- Minor bug fixes

### Other
- Add Release Notes
- Update Docker installation scripts

## v3.0 (June 5, 2020) [![DOI](https://zenodo.org/badge/161701589.svg)](https://zenodo.org/badge/latestdoi/161701589)

Initial 3.0 Release. For more information, see [iReceptor v3.0](https://ireceptor.org/ireceptor-3).
