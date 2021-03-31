require 'rails_helper'

RSpec.describe 'Leads', type: :request do
  describe 'GET /leads' do
    it 'returns list of all leads' do
      lead1 = create(:lead, name: 'Lead 1')
      lead2 = create(:lead, name: 'Lead 2')
      lead3 = create(:lead, name: 'Lead 3')

      get '/api/v1/leads'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      leads = json['data']
      lead1 = leads[0]
      lead2 = leads[1]
      lead3 = leads[2]
      expect(lead1['attributes']['name']).to eq 'Lead 1'
      expect(lead1['type']).to eq 'leads'
      expect(lead1['links']['self']).to eq "http://www.example.com/api/v1/leads/#{lead1['id']}"
      expect(lead2['attributes']['name']).to eq 'Lead 2'
      expect(lead2['type']).to eq 'leads'
      expect(lead2['links']['self']).to eq "http://www.example.com/api/v1/leads/#{lead2['id']}"
      expect(lead3['attributes']['name']).to eq 'Lead 3'
      expect(lead3['type']).to eq 'leads'
      expect(lead3['links']['self']).to eq "http://www.example.com/api/v1/leads/#{lead3['id']}"
      expect(json['data'].count).to eq 3
    end

    context 'when sort parameter is provided' do
      context 'when name parameter is provided' do
        it 'returns leads sorted ascending by name' do
          lead1 = create(:lead, name: 'Lead B')
          lead2 = create(:lead, name: 'Lead C')
          lead3 = create(:lead, name: 'Lead A')

          get '/api/v1/leads?sort=name'

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          leads = json['data']
          lead1 = leads[0]
          lead2 = leads[1]
          lead3 = leads[2]
          expect(lead1['attributes']['name']).to eq 'Lead A'
          expect(lead1['type']).to eq 'leads'
          expect(lead1['links']['self']).to eq "http://www.example.com/api/v1/leads/#{lead1['id']}"
          expect(lead2['attributes']['name']).to eq 'Lead B'
          expect(lead2['type']).to eq 'leads'
          expect(lead2['links']['self']).to eq "http://www.example.com/api/v1/leads/#{lead2['id']}"
          expect(lead3['attributes']['name']).to eq 'Lead C'
          expect(lead3['type']).to eq 'leads'
          expect(lead3['links']['self']).to eq "http://www.example.com/api/v1/leads/#{lead3['id']}"
          expect(json['data'].count).to eq 3
        end
      end
    end
  end

  describe 'GET /leads/:id' do
    it 'returns lead by id' do
      lead1 = create(:lead, name: 'Lead 1')

      get "/api/v1/leads/#{lead1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq 'Lead 1'
      expect(json['data']['type']).to eq 'leads'
    end

    context 'when no lead_id matches given id' do
      it 'returns 404 http code, not found' do
        get '/api/v1/leads/1'

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:not_found)
        expect(errors[0]['status']).to eq('404')
        expect(errors[0]['detail']).to eq('The record identified by 1 could not be found.')
      end
    end
  end

  describe 'POST /leads' do
    it 'creates new lead' do
      hash = {
        data: {
          type: 'leads',
          attributes: {
            name: 'client'
          }
        }
      }.stringify_keys.to_json
      headers = { 'ACCEPT' => 'application/vnd.api+json', 'CONTENT_TYPE' => 'application/vnd.api+json' }

      post '/api/v1/leads', params: hash, headers: headers

      json = JSON.parse(response.body)
      expect(response.content_type).to eq('application/vnd.api+json')
      expect(response).to have_http_status(:created)
      expect(json['data']['attributes']['name']).to eq 'client'
    end
  end

  describe 'PUT /leads/:id' do
    it 'updates given lead' do
      lead = create(:lead, name: 'new lead')
      headers = { 'ACCEPT' => 'application/vnd.api+json', 'CONTENT_TYPE' => 'application/vnd.api+json' }
      hash = {
        data: {
          type: 'leads',
          id: lead.id,
          attributes: {
            name: 'updated lead'
          }
        }
      }.stringify_keys.to_json

      expect {
        put "/api/v1/leads/#{lead.id}", params: hash, headers: headers
      }.to change { lead.reload.name }.from('new lead').to('updated lead')

      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq 'updated lead'
    end

    context 'when no lead_id matches given id' do
      it 'returns 404 http code, not found' do
        headers = { 'ACCEPT' => 'application/vnd.api+json', 'CONTENT_TYPE' => 'application/vnd.api+json' }
        hash = {
          data: {
            type: 'leads',
            id: '1',
            attributes: {
              name: 'newClient'
            }
          }
        }.stringify_keys.to_json

        put '/api/v1/leads/1', params: hash, headers: headers

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:not_found)
        expect(errors[0]['status']).to eq('404')
        expect(errors[0]['detail']).to eq('The record identified by 1 could not be found.')
      end
    end
  end

  describe 'DELETE /leads/:id' do
    it 'removes lead by id' do
      lead_to_remove = create(:lead, name: 'Lead 1')

      delete "/api/v1/leads/#{lead_to_remove.id}"

      expect(response).to have_http_status(:success)
    end
    context 'when no id matches given id' do
      it 'returns 404 http code, not found' do
        delete '/api/v1/leads/1'

        json = JSON.parse(response.body)
        errors = json.fetch('errors')
        expect(response).to have_http_status(:not_found)
        expect(errors[0]['status']).to eq('404')
        expect(errors[0]['detail']).to eq('The record identified by 1 could not be found.')
      end
    end
  end
end