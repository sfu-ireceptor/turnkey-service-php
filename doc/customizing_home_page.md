# Customizing the home page

How to customize the web page at https://localhost/


## Solution 1 (recommended) - Customizing the defaults
[Customize the /airr/v1/info entry point](customizing_info_entry_point.md), and those values (repository name, contact URL, contact email) will also be changed on the home page.

## Solution 2 - Build your own home page

Create an ``index.html`` file in the ``.home`` folder. It will be shown instead of the default home page.

Note: you can put into the ``.home`` folder other required files: CSS, Javascript, images, other HTML files, etc.