require 'rails_helper'

RSpec.describe 'Resources', type: :request do
  describe 'GET /resources' do
    it 'returns list of all resources' do
      resource_type1 = create(:resource_type, name: 'article')
      resource1 = create(:resource, name: 'ruby article', description: 'short description',
                         url: 'www.sample.com/article')
      resource2 = create(:resource, name: 'ember project', description: 'long description',
                         url: 'www.sample.com/project')

      get '/api/v1/resources'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      resources = json['data']
      resource1 = resources[0]
      resource2 = resources[1]
      expect(resource1['attributes']['name']).to eq 'ruby article'
      expect(resource1['attributes']['description']).to eq 'short description'
      expect(resource1['attributes']['url']).to eq 'www.sample.com/article'
      expect(resource1['type']).to eq 'resources'
      expect(resource1['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource1['id']}"
      expect(resource2['attributes']['name']).to eq 'ember project'
      expect(resource2['attributes']['description']).to eq 'long description'
      expect(resource2['attributes']['url']).to eq 'www.sample.com/project'
      expect(resource2['type']).to eq 'resources'
      expect(resource2['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource2['id']}"
      expect(json['data'].count).to eq 2
    end

    context 'when sort parameter is provided' do
      context 'when provided parameter is name' do
        it 'returns resources sorted ascending by name' do
          resource1 = create(:resource, name: 'ruby article')
          resource2 = create(:resource, name: 'blog post about react')
          resource3 = create(:resource, name: 'ember project')

          get '/api/v1/resources?sort=name'

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          resources = json['data']
          first_resource = resources[0]
          second_resource = resources[1]
          third_resource = resources[2]
          expect(first_resource['attributes']['name']).to eq 'blog post about react'
          expect(first_resource['type']).to eq 'resources'
          expect(first_resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource2['id']}"
          expect(second_resource['attributes']['name']).to eq 'ember project'
          expect(second_resource['type']).to eq 'resources'
          expect(second_resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource3['id']}"
          expect(third_resource['attributes']['name']).to eq 'ruby article'
          expect(third_resource['type']).to eq 'resources'
          expect(third_resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource1['id']}"
          expect(json['data'].count).to eq 3
        end
      end

      context 'when provided parameter is description' do
        it 'returns resources sorted ascending by description' do
          resource1 = create(:resource, name: 'ruby article', description: 'short description')
          resource2 = create(:resource, name: 'ember project', description: 'long description')
          resource3 = create(:resource, name: 'blog post about react', description: 'some description')

          get '/api/v1/resources?sort=description'

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          resources = json['data']
          first_resource = resources[0]
          second_resource = resources[1]
          third_resource = resources[2]
          expect(first_resource['attributes']['name']).to eq 'ember project'
          expect(first_resource['attributes']['description']).to eq 'long description'
          expect(first_resource['type']).to eq 'resources'
          expect(first_resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource2['id']}"
          expect(second_resource['attributes']['name']).to eq 'ruby article'
          expect(second_resource['attributes']['description']).to eq 'short description'
          expect(second_resource['type']).to eq 'resources'
          expect(second_resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource1['id']}"
          expect(third_resource['attributes']['name']).to eq 'blog post about react'
          expect(third_resource['attributes']['description']).to eq 'some description'
          expect(third_resource['type']).to eq 'resources'
          expect(third_resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource3['id']}"
          expect(json['data'].count).to eq 3
        end
      end
    end

    context 'when filter parameter is given' do
      context 'when provided parameter is resource type id' do
        it 'returns resources by given resource type' do
          resource_type1 = create(:resource_type, name: 'article')
          resource_type2 = create(:resource_type, name: 'project')
          resource1 = create(:resource, name: 'ruby article', resource_type: resource_type1)
          resource2 = create(:resource, name: 'ember project', resource_type: resource_type2)

          get '/api/v1/resources', params: { filter: { resource_type_id: resource_type2.id } }

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          resources = json['data']
          resource = resources[0]
          expect(resource['attributes']['name']).to eq 'ember project'
          expect(resource['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource['id']}"
          expect(resource['type']).to eq 'resources'
          expect(json['data'].count).to eq 1
        end
      end
    end

    context 'when paginate parameter is given' do
      it 'returns first page with 2 resources' do
        resource_ruby = create(:resource, name: 'Ruby article')
        resource_js = create(:resource, name: 'JS article')
        create(:resource, name: 'other article')

        get '/api/v1/resources', params: { page: { size: 2 } }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        resources = json['data']
        resource1 = resources[0]
        expect(resources.count).to eq 2
        expect(resource1['type']).to eq 'resources'
        expect(resource1['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource_ruby.id}"
        expect(resource1['attributes']['name']).to eq 'Ruby article'
        resource2 = resources[1]
        expect(resource2['type']).to eq 'resources'
        expect(resource2['links']['self']).to eq "http://www.example.com/api/v1/resources/#{resource_js.id}"
        expect(resource2['attributes']['name']).to eq 'JS article'
        expect(json['links']['next']).to eq 'http://www.example.com/api/v1/resources?page%5Bnumber%5D=2&page%5Bsize%5D=2'
      end
    end
  end

  describe 'GET /resources/:id' do
    it 'returns resource by id' do
      resource1 = create(:resource, name: 'ruby article')

      get "/api/v1/resources/#{resource1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq 'ruby article'
    end

    context 'when no resource_id matches given id' do
      it 'returns 404 http code, not found' do
        get '/api/v1/resources/1'

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:not_found)
        expect(errors[0]['status']).to eq('404')
        expect(errors[0]['detail']).to eq('The record identified by 1 could not be found.')
      end
    end
  end

  describe 'POST /resources' do
    it 'creates new resource' do
      resource_type1 = create(:resource_type, name: 'article')
      params = {
        data: {
          type: 'resources',
          attributes: {
            name: 'article',
            description: 'description of the article',
            url: 'www.samplesite.com/article'
          },
          relationships: {
            'resource-type': {
              data: {
                type: 'resource-types',
                id: resource_type1.id
              }
            }
          }
        }
      }.stringify_keys.to_json

      post_api('/api/v1/resources', params)

      json = JSON.parse(response.body)
      expect(response.content_type).to eq('application/vnd.api+json')
      expect(response).to have_http_status(:created)
      expect(json['data']['attributes']['name']).to eq 'article'
      expect(json['data']['attributes']['description']).to eq 'description of the article'
      expect(json['data']['attributes']['url']).to eq 'www.samplesite.com/article'
    end

    context 'when tag category parameters is not provided' do
      it 'returns 422 http code, unprocessable_entity' do
        params = {
          data: {
            type: 'resources',
            attributes: {
              name: 'article',
              description: 'description of the article',
              url: 'www.samplesite.com/article'
            }
          }
        }.stringify_keys.to_json

        post_api('/api/v1/resources', params)

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:unprocessable_entity)
        expect(errors[0]['status']).to eq('422')
        expect(errors[0]['detail']).to eq("resource-type - can't be blank")
      end
    end
  end

  describe 'PUT /resources/:id' do
    it 'updates given resource' do
      resource_type1 = create(:resource_type, name: 'article')
      resource = create(:resource, name: 'new resource', description: 'old description', url: 'www.oldsite.com',
                        resource_type: resource_type1)
      headers = { 'ACCEPT' => 'application/vnd.api+json', 'CONTENT_TYPE' => 'application/vnd.api+json' }
      params = {
        data: {
          type: 'resources',
          id: resource.id,
          attributes: {
            name: 'updated resource',
            description: 'new description of the article',
            url: 'www.newsite.com'
          }, relationships: {
            'resource-type': {
              data: {
                type: 'resource-types',
                id: resource_type1.id
              }
            }
          }
        }
      }.stringify_keys.to_json

      expect {
        put "/api/v1/resources/#{resource.id}", params: params, headers: headers
      }.to change { resource.reload.name }.from('new resource').to('updated resource')

      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq 'updated resource'
      expect(json['data']['attributes']['description']).to eq 'new description of the article'
      expect(json['data']['attributes']['url']).to eq 'www.newsite.com'
    end

    context 'when no resource_id matches given id' do
      it 'returns 404 http code, not found' do
        headers = { 'ACCEPT' => 'application/vnd.api+json', 'CONTENT_TYPE' => 'application/vnd.api+json' }
        hash = {
          data: {
            type: 'resources',
            id: '1',
            attributes: {
              name: 'new article'
            }
          }
        }.stringify_keys.to_json

        put '/api/v1/resources/1', params: hash, headers: headers

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:not_found)
        expect(errors[0]['status']).to eq('404')
        expect(errors[0]['detail']).to eq('The record identified by 1 could not be found.')
      end
    end
  end

  describe 'DELETE /resources/:id' do
    it 'removes resource by id' do
      resource_to_remove = create(:resource, name: 'resource 1')

      delete "/api/v1/resources/#{resource_to_remove.id}"

      expect(response).to have_http_status(204)
    end

    context 'when no id matches given id' do
      it 'returns 404 http code, not found' do
        delete '/api/v1/resources/1'

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:not_found)
        expect(errors[0]['status']).to eq('404')
        expect(errors[0]['detail']).to eq('The record identified by 1 could not be found.')
      end
    end
  end

  def post_api(path, params)
    post path, params: params, headers: headers
  end

  def headers
    { 'ACCEPT' => 'application/vnd.api+json', 'CONTENT_TYPE' => 'application/vnd.api+json' }
  end
end