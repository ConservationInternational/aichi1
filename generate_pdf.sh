ssh ubuntu@54.86.66.208 "xvfb-run wkhtmltopdf http://34.195.2.46:3000/factsheet.html test.pdf"

scp ubuntu@54.86.66.208:test.pdf ~/aichi1/myapp/public/"Biodiversity Engagement Indicator.pdf"

