---
# Leave the homepage title empty to use the site title
title: ''
summary: ''
date: 2022-10-24
type: landing

design:
  spacing: '6rem'

sections:
  - block: resume-biography-3
    id: about
    content:
      username: admin
      text: ''
      headings:
        about: 'About'
        education: ''
        interests: ''
    design:
      background:
        gradient_mesh:
          enable: true
      name:
        size: md
      avatar:
        size: medium
        shape: circle

  - block: markdown
    content:
      title: Research and Engineering
      subtitle: ''
      text: |-
        I work on multimodal AI, computer vision, sensor fusion, and production ML systems.

        This site collects technical writing, publications, and project notes from work on maritime autonomy, multi-object tracking, and scalable AI systems.
    design:
      columns: '1'

  - block: collection
    id: featured
    content:
      title: Featured Publications
      filters:
        folders:
          - publication
        featured_only: true
    design:
      view: article-grid
      columns: 2

  - block: collection
    id: posts
    content:
      title: Posts
      text: Latest writing from this site.
      filters:
        folders:
          - post
      count: 6
      order: desc
    design:
      view: card
      columns: 2
---
