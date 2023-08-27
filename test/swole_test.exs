defmodule SwoleTest do
  use ExUnit.Case
  alias Plug.Conn
  alias Phoenix.ConnTest
  doctest Swole

  @test_spec %Swole.APISpec{
    openapi: "3.1.0",
    servers: [%{description: "", url: "www.example.com"}],
    paths: %{
      "/api/plants" => %{
        "description" => "",
        "get" => %{
          deprecated: false,
          description: "index lists all plants",
          operationId: "list_plants",
          responses: %{
            200 => %{
              content: %{
                "application/json" => %{
                  schema: %{
                    properties: [%{"data" => %{items: [], type: "array"}}],
                    type: "object"
                  }
                }
              },
              description: "index lists all plants"
            }
          },
          tags: ["BuffWeb.PlantController"]
        },
        "parameters" => [],
        "post" => %{
          deprecated: false,
          description:
            "create plant renders errors when data is invalid or\ncreate plant renders plant when data is valid",
          operationId: "create_plant",
          requestBody: %{
            content: %{
              "application/json" => %{
                schema: %{
                  example: %{
                    "plant" => %{
                      "description" => "some description",
                      "name" => "some name"
                    }
                  },
                  schema: %{
                    properties: [
                      %{
                        "plant" => %{
                          properties: [
                            %{"description" => %{type: "string"}},
                            %{"name" => %{type: "string"}}
                          ],
                          type: "object"
                        }
                      }
                    ],
                    type: "object"
                  }
                }
              }
            },
            description:
              "create plant renders errors when data is invalid or\ncreate plant renders plant when data is valid",
            required: true
          },
          responses: %{
            201 => %{
              content: %{
                "application/json" => %{
                  schema: %{
                    properties: [
                      %{
                        "data" => %{
                          properties: [
                            %{"description" => %{type: "string"}},
                            %{"id" => %{type: "integer"}},
                            %{"name" => %{type: "string"}}
                          ],
                          type: "object"
                        }
                      }
                    ],
                    type: "object"
                  }
                }
              },
              description: "create plant renders plant when data is valid"
            },
            422 => %{
              content: %{
                "application/json" => %{
                  schema: %{
                    properties: [
                      %{
                        "errors" => %{
                          properties: [
                            %{
                              "description" => %{
                                items: [%{type: "string"}],
                                type: "array"
                              }
                            },
                            %{
                              "name" => %{
                                items: [%{type: "string"}],
                                type: "array"
                              }
                            }
                          ],
                          type: "object"
                        }
                      }
                    ],
                    type: "object"
                  }
                }
              },
              description: "create plant renders errors when data is invalid"
            }
          },
          tags: ["BuffWeb.PlantController"]
        },
        "summary" => ""
      },
      "/api/plants/{id}" => %{
        "delete" => %{
          deprecated: false,
          description: "delete plant deletes chosen plant",
          operationId: "delete_plant",
          parameters: [
            %{
              description:
                "### Path: `/api/plants/:id`\n\n  Example: `www.example.com/api/plants/644`\n",
              in: "path",
              name: "id",
              required: true,
              schema: %{type: "string"}
            }
          ],
          responses: %{
            204 => %{
              content: %{"text/plain" => %{schema: %{type: "string"}}},
              description: "delete plant deletes chosen plant"
            }
          },
          tags: ["BuffWeb.PlantController"]
        },
        "description" => "",
        "parameters" => [
          %{
            description:
              "### Path: `/api/plants/:id`\n\n  Example: `www.example.com/api/plants/645`\n",
            in: "path",
            name: "id",
            required: true,
            schema: %{type: "string"}
          }
        ],
        "put" => %{
          deprecated: false,
          description:
            "update plant renders errors when data is invalid or\nupdate plant renders plant when data is valid",
          operationId: "update_plant",
          parameters: [
            %{
              description:
                "### Path: `/api/plants/:id`\n\n  Example: `www.example.com/api/plants/645`\n",
              in: "path",
              name: "id",
              required: true,
              schema: %{type: "string"}
            }
          ],
          requestBody: %{
            content: %{
              "application/json" => %{
                schema: %{
                  example: %{
                    "plant" => %{
                      "description" => "some updated description",
                      "name" => "some updated name"
                    }
                  },
                  schema: %{
                    properties: [
                      %{
                        "plant" => %{
                          properties: [
                            %{"description" => %{type: "string"}},
                            %{"name" => %{type: "string"}}
                          ],
                          type: "object"
                        }
                      }
                    ],
                    type: "object"
                  }
                }
              }
            },
            description:
              "update plant renders errors when data is invalid or\nupdate plant renders plant when data is valid",
            required: true
          },
          responses: %{
            200 => %{
              content: %{
                "application/json" => %{
                  schema: %{
                    properties: [
                      %{
                        "data" => %{
                          properties: [
                            %{"description" => %{type: "string"}},
                            %{"id" => %{type: "integer"}},
                            %{"name" => %{type: "string"}}
                          ],
                          type: "object"
                        }
                      }
                    ],
                    type: "object"
                  }
                }
              },
              description: "update plant renders plant when data is valid"
            },
            422 => %{
              content: %{
                "application/json" => %{
                  schema: %{
                    properties: [
                      %{
                        "errors" => %{
                          properties: [
                            %{
                              "description" => %{
                                items: [%{type: "string"}],
                                type: "array"
                              }
                            },
                            %{
                              "name" => %{
                                items: [%{type: "string"}],
                                type: "array"
                              }
                            }
                          ],
                          type: "object"
                        }
                      }
                    ],
                    type: "object"
                  }
                }
              },
              description: "update plant renders errors when data is invalid"
            }
          },
          tags: ["BuffWeb.PlantController"]
        },
        "summary" => ""
      }
    },
    components: nil,
    security: nil,
    tags: [
      %{
        "description" => "BuffWeb.PlantController Actions",
        "name" => "BuffWeb.PlantController"
      }
    ],
    externalDocs: nil,
    info: %{"title" => "Buff API", "version" => "0.1.0"}
  }

  describe "encode specs to json" do
    test "can encode the api spec to json" do
      assert {:ok, _json} = Swole.JSONEncoder.encode(@test_spec)
    end
  end
end
