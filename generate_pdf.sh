ssh ubuntu@54.86.45.107 "xvfb-run wkhtmltopdf http://34.195.2.46/factsheet.html test.pdf"

ssh ubuntu@54.86.45.107 "pdftk test.pdf cat 1-2 output test2.pdf"

scp ubuntu@54.86.45.107:test2.pdf ~/aichi1/myapp/public/"Biodiversity Engagement Indicator.pdf"

