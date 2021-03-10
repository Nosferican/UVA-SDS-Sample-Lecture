# GraphQL API

## Materials to read / watch before class:

- [GraphQL](https://graphql.org/learn/) website
- [How to GraphQL](https://www.howtographql.com/basics/0-introduction/) (GraphQL Fundamentals parts 1-4)

## Requirements

- If you have not, request a [GitHub Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

- Download [GraphiQL](https://www.electronjs.org/apps/graphiql)

- Set up the GraphiQL environment through the following configuration

  - GraphQL Endpoint: https://api.github.com/graphql
  - Headers:
    - User-Agent: {{Your GitHub Login}}
    - Authorization: bearer {{Your GitHub PAT}}

## Introduction

GraphQL is a query language for your API that serves as an alternative to REST. It is most suitable for data that is related (i.e., graphs) and can solve various limitations compared to REST API such as:

- Over-fetching: obtaining more data than required from a request
- Under-fetching: need to make multiple requests to obtain the desired data
- Strong typing: allows for predictable results

## Code Along

!!! tip

    Be sure to check out the documentation explorer and provided hints by the GUI while learning the GraphQL language and new API.

### Search

Using the [search syntax](https://docs.github.com/en/github/searching-for-information-on-github/understanding-the-search-syntax), find the:
- Global node ID
- Date when repository was created on GitHub
- Name of the default branch

for three repositories that meet the following criteria:

- is a public repository
- created between 2021-01-01 and 2021-01-05
- is Zlib licensed

#### Solution

```
query DefaultBranch($query: String!, $type: SearchType!, $first: Int) {
  search(query: $query, type: $type, first: $first) {
    edges {
      node {
        ... on Repository {
          id
          defaultBranchRef {
            name
          }
          createdAt
        }
      }
    }
  }
}
```
```
{
    "query": "is:public license:zlib created:2021-01-01T00:00:00Z..2021-01-05T00:00:00Z",
    "type": "REPOSITORY",
    "first": 3
}
```
which yields something like
```
{
  "data": {
    "search": {
      "repositoryCount": 3,
      "edges": [
        {
          "node": {
            "id": "MDEwOlJlcG9zaXRvcnkzMjcxNDI3NDQ=",
            "defaultBranchRef": {
              "name": "main"
            },
            "createdAt": "2021-01-05T23:11:04Z"
          }
        },
        {
          "node": {
            "id": "MDEwOlJlcG9zaXRvcnkzMjYyMTQ0NDM=",
            "defaultBranchRef": {
              "name": "master"
            },
            "createdAt": "2021-01-02T15:43:08Z"
          }
        },
        {
          "node": {
            "id": "MDEwOlJlcG9zaXRvcnkzMjYyMzA1NTQ=",
            "defaultBranchRef": {
              "name": "master"
            },
            "createdAt": "2021-01-02T17:04:19Z"
          }
        }
      ]
    }
  }
}
```

!!! warning

    Pay attention to being explicit with the timezones.

!!! tip

    Using variables allows to keep code DRY.

!!! info

    Compared to the REST endpoint, the GraphQL allows to not overfetch.

### Primary Language

Find the programming language for the repositories above.

#### Solution

```
fragment PrimaryLanguage on Repository {
  id
  primaryLanguage {
    name
  }
}

query Description($ids: [ID!]!) {
  nodes(ids: $ids) {
    ...PrimaryLanguage
  }
}
```
```
{
    "ids": ["MDEwOlJlcG9zaXRvcnkzMjcxNDI3NDQ=", "MDEwOlJlcG9zaXRvcnkzMjYyMTQ0NDM=", "MDEwOlJlcG9zaXRvcnkzMjYyMzA1NTQ="]
}
```
```
{
  "data": {
    "nodes": [
      {
        "id": "MDEwOlJlcG9zaXRvcnkzMjcxNDI3NDQ=",
        "primaryLanguage": {
          "name": "C#"
        }
      },
      {
        "id": "MDEwOlJlcG9zaXRvcnkzMjYyMTQ0NDM=",
        "primaryLanguage": {
          "name": "C"
        }
      },
      {
        "id": "MDEwOlJlcG9zaXRvcnkzMjYyMzA1NTQ=",
        "primaryLanguage": {
          "name": "Python"
        }
      }
    ]
  }
}
```

!!! tip

    When requerying, it is best to use the global node ID.

!!! tip

    You can use fragments to achieve cleaner queries.

!!! info

    Compared to a REST framework, one can query multiple nodes (e.g., 100 nodes per `nodes` and multiple aliased nodes) allowing for an efficiency gain of tens of thousands.

### Commits

Find the first 5 user accounts of the commit authors for each commit between `2020-12-01..2021-01-01` for the repository `JuliaLang/Julia` and between `2020-12-14..2021-01-01` for the repository `uva-bi-sdad/GHOST.jl` based on the default branches.

```
fragment Contributors on CommitHistoryConnection {
  pageInfo {
    endCursor
    hasNextPage
  }
  edges {
    node {
      authors(first: 5) {
        edges {
          node {
            user {
              id
            }
          }
        }
      }
    }
  }
}

query CommitsOfInterest($x: GitTimestamp!, $y: GitTimestamp!, $z: GitTimestamp!, $first: Int!) {
  _1: repository(owner: "JuliaLang", name: "Julia") {
    ... on Repository {
      defaultBranchRef {
        id
        target {
          ... on Commit {
            history(since: $x, until: $z, first: $first) {
              ...Contributors
            }
          }
        }
      }
    }
  }
  _2: repository(owner: "uva-bi-sdad", name: "GHOST.jl") {
    ... on Repository {
      defaultBranchRef {
        id
        target {
          ... on Commit {
            history(since: $y, until: $z, first: $first) {
              ...Contributors
            }
          }
        }
      }
    }
  }
}
```
```
{
    "x": "2020-12-01T00:00:00Z",
    "y": "2020-12-14T00:00:00Z",
    "z": "2021-01-01T00:00:00Z",
    "first": 5
}
```
yields
```
{
  "data": {
    "_1": {
      "defaultBranchRef": {
        "id": "MDM6UmVmMTY0NDE5NjpyZWZzL2hlYWRzL21hc3Rlcg==",
        "target": {
          "history": {
            "pageInfo": {
              "endCursor": "b4c79e76fb699cf67d0e6b14ecfa75b1aaca923f 4",
              "hasNextPage": true
            },
            "edges": [
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjEyOTE2NzE="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjEyOTE2NzE="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjEyOTE2NzE="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjgyODY0Mw=="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjEzMDkyMA=="
                          }
                        }
                      }
                    ]
                  }
                }
              }
            ]
          }
        }
      }
    },
    "_2": {
      "defaultBranchRef": {
        "id": "MDM6UmVmMjM4MzU3MTEyOnJlZnMvaGVhZHMvbWFpbg==",
        "target": {
          "history": {
            "pageInfo": {
              "endCursor": "588239801761551e5b6f5becfc7ef987adfade07 3",
              "hasNextPage": false
            },
            "edges": [
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjI1MjkzMjk="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjI1MjkzMjk="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjI1MjkzMjk="
                          }
                        }
                      }
                    ]
                  }
                }
              },
              {
                "node": {
                  "authors": {
                    "edges": [
                      {
                        "node": {
                          "user": {
                            "id": "MDQ6VXNlcjI1MjkzMjk="
                          }
                        }
                      }
                    ]
                  }
                }
              }
            ]
          }
        }
      }
    }
  }
}
```

**Tips**

!!! tip

    Aliasing allows you to reduce the number of requests needed to collect the information you want.

!!! info

    You can set up the structure for pagination during the initial request.

!!! info

    Notice that through REST endpoints one would need to access multiple resources through multiple requests.

!!! warning

    GraphQL may have hard limits on the cost of the query and possible number of data points, but most likely one may incur in a timeout when requesting too much data and those limits are not known until execution time.

For paginating, we can adapt the code by passing the cursors as variables.

```
fragment Contributors on CommitHistoryConnection {
  pageInfo {
    endCursor
  }
  edges {
    node {
      authors(first: 5) {
        edges {
          node {
            user {
              id
            }
          }
        }
      }
    }
  }
}

query CommitsOfInterest($x: GitTimestamp!, $y: GitTimestamp!, $z: GitTimestamp!, $first: Int!, $x_cur: String, $y_cur: String) {
  _1: node(id: "MDM6UmVmMTY0NDE5NjpyZWZzL2hlYWRzL21hc3Rlcg==") {
    ... on Ref {
      id
      target {
        ... on Commit {
          history(since: $x, until: $z, first: $first, after: $x_cur) {
            ...Contributors
          }
        }
      }
    }
  }
  _2: node(id: "MDM6UmVmMjM4MzU3MTEyOnJlZnMvaGVhZHMvbWFpbg==") {
    ... on Ref {
      id
      target {
        ... on Commit {
          history(since: $y, until: $z, first: $first, after: $y_cur) {
            ...Contributors
          }
        }
      }
    }
  }
}
```
```
{
    "x": "2020-12-01T00:00:00Z",
    "y": "2020-12-14T00:00:00Z",
    "z": "2021-01-01T00:00:00Z",
    "first": 5,
    "x_cur": "b4c79e76fb699cf67d0e6b14ecfa75b1aaca923f 4",
    "y_cur": "588239801761551e5b6f5becfc7ef987adfade07 3"
}
```
```
{
  "data": {
    "_1": {
      "id": "MDM6UmVmMTY0NDE5NjpyZWZzL2hlYWRzL21hc3Rlcg==",
      "target": {
        "history": {
          "pageInfo": {
            "endCursor": "b4c79e76fb699cf67d0e6b14ecfa75b1aaca923f 9",
            "hasNextPage": true
          },
          "edges": [
            {
              "node": {
                "authors": {
                  "edges": [
                    {
                      "node": {
                        "user": {
                          "id": "MDQ6VXNlcjEzMDkyMA=="
                        }
                      }
                    }
                  ]
                }
              }
            },
            {
              "node": {
                "authors": {
                  "edges": [
                    {
                      "node": {
                        "user": {
                          "id": "MDQ6VXNlcjEzMDkyMA=="
                        }
                      }
                    }
                  ]
                }
              }
            },
            {
              "node": {
                "authors": {
                  "edges": [
                    {
                      "node": {
                        "user": {
                          "id": "MDQ6VXNlcjUyMjA1Mjg="
                        }
                      }
                    }
                  ]
                }
              }
            },
            {
              "node": {
                "authors": {
                  "edges": [
                    {
                      "node": {
                        "user": {
                          "id": "MDQ6VXNlcjQyMjgwNzk0"
                        }
                      }
                    }
                  ]
                }
              }
            },
            {
              "node": {
                "authors": {
                  "edges": [
                    {
                      "node": {
                        "user": {
                          "id": "MDQ6VXNlcjEzMDkyMA=="
                        }
                      }
                    }
                  ]
                }
              }
            }
          ]
        }
      }
    },
    "_2": {
      "id": "MDM6UmVmMjM4MzU3MTEyOnJlZnMvaGVhZHMvbWFpbg==",
      "target": {
        "history": {
          "pageInfo": {
            "endCursor": null,
            "hasNextPage": false
          },
          "edges": []
        }
      }
    }
  }
}
```

!!! info

    When paginating outside the range, the `endCursor` is null.

!!! info

    Edges can be empty if there are no results.

## Class Exercise

Convert the pipeline from the graphical user interface to a program using your favorite GraphQL [client implementations](https://graphql.org/code/). Get familiar with programatically paginating results.

!!! tip

    Using your favorite programming language get familiar with the available GraphQL client packages. You will likely also want to use a JSON library for reading the payload.

!!! tip

    You can mix and match REST and GraphQL functionality as needed. For example, some features might only be available through a REST endpoint or may be more efficient (e.g., conditional requests, no cost queries). Consider using https://api.github.com/rate_limit for querying and managing your rate limits in your program.

!!! tip

    Try querying for a repository or user that is not available (e.g., is not public) to discover the behavior and develop an "error handling" strategy.
