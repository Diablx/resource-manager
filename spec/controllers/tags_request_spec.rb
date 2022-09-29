require 'rails_helper'

RSpec.describe "Tags", type: :request do
    describe "GET /tags" do

    end    
    describe "GET /tags/:id" do
        it "returns tag by id" do
            
        end
        context "when no tag_id matches given id" do
            it 'returns error' do
                
            end
        end
    end
    describe "POST /tags" do
        it "creates new tag" do
            
        end
        context 'when no tag_category selected' do
            it 'returns error' do
                
            end
        end
    end
    describe "PUT /tags/:id" do
        it "updates tag by id" do
            
        end
        context 'when no tag_id matches given id' do
            it 'returns error' do
                
            end
        end
        context 'when no tag_category selected' do
            it 'returns error' do
                
            end
        end
    end
    describe "DELETE /tags/:id" do
        it "removes tag by id" do
            
        end
        context 'when no id matches given id' do
            it 'returns error' do
                
            end
        end
    end
end
