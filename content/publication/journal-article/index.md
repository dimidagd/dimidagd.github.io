---
title: 'Cyber-resilience for marine navigation by information fusion and change detection'

# Authors
# If you created a profile for a user (e.g. the default `admin` user), write the username (folder name) here
# and it will be replaced with their full name and linked to their profile.
authors:
  - admin
  - Mogens Blanke
  - Rasmus Hjorth Andersen
  - Roberto Galeazzi

# Author notes (optional)
# author_notes:
#   - 'Equal contribution'
#   - 'Equal contribution'

date: '2022-12-01T00:00:00Z'
doi: '10.1016/j.oceaneng.2022.112605'

# Schedule page publish date (NOT publication's date).
publishDate: '2017-01-01T00:00:00Z'

# Publication type.
# Accepts a single type but formatted as a YAML list (for Hugo requirements).
# Enter a publication type from the CSL standard.
publication_types: ['paper-journal']

# Publication name and optional abbreviated publication name.
publication: Ocean Engineering
publication_short: Ocean Engineering

abstract: Cyber-resilience is an increasing concern for autonomous navigation of marine vessels. This paper scrutinizes cyber-resilience properties of marine navigation through a prism with three edges, multiple sensor information fusion, diagnosis of not-normal behaviours, and change detection. It proposes a two-stage estimator for diagnosis and mitigation of sensor signals used for coastal navigation. Developing a Likelihood Field approach, the first stage extracts shoreline features from radar and matches them to the electronic navigation chart. The second stage associates buoy and beacon features from the radar with chart information. Using real data logged at sea tests combined with simulated spoofing, the paper verifies the ability to timely diagnose and isolate an attempt to compromise position measurements. A new approach is suggested for high level processing of received data to evaluate their consistency, which is agnostic to the underlying technology of the individual sensory input. A combined generalized likelihood ratio test using both parametric Gaussian modelling and Kernel Density Estimation is suggested and compared with a detector using only either of two. The paper shows how the detection of deviations from nominal behaviour is possible when the navigation sensor is under attack or defects occur.

# Summary. An optional shortened abstract.
summary: The study explores cyber-resilience in autonomous marine navigation by proposing a two-stage estimator for diagnosing and mitigating sensor signal anomalies, tested through real and simulated sea trials.

tags: []

# Display this page in the Featured widget?
featured: true

# Custom links (uncomment lines below)
links:
- name: DTU orbit
  url: https://orbit.dtu.dk/en/publications/cyber-resilience-for-marine-navigation-by-information-fusion-and-
- name: arXiv
  url: https://arxiv.org/abs/2202.03268

url_pdf: 'https://www.sciencedirect.com/science/article/pii/S0029801822018881'
# url_code: 'https://github.com/HugoBlox/hugo-blox-builder'
# url_dataset: 'https://github.com/HugoBlox/hugo-blox-builder'
# url_poster: ''
url_project: 'https://www.safenavsystem.com/'
# url_slides: ''
# url_source: 'https://github.com/HugoBlox/hugo-blox-builder'
# url_video: 'https://youtube.com'

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
image:
  caption: 'Image credit: [**Unsplash**](https://unsplash.com/photos/pLCdAaMFLTE)'
  focal_point: ''
  preview_only: true

# Associated Projects (optional).
#   Associate this publication with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `internal-project` references `content/project/internal-project/index.md`.
#   Otherwise, set `projects: []`.
projects:
  - []

# Slides (optional).
#   Associate this publication with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides: "example"` references `content/slides/example/index.md`.
#   Otherwise, set `slides: ""`.
slides: ""
---

<!-- {{% callout note %}}
Click the _Cite_ button above to demo the feature to enable visitors to import publication metadata into their reference management software.
{{% /callout %}}

{{% callout note %}}
Create your slides in Markdown - click the _Slides_ button to check out the example.
{{% /callout %}}

Add the publication's **full text** or **supplementary notes** here. You can use rich formatting such as including [code, math, and images](https://docs.hugoblox.com/content/writing-markdown-latex/). -->
