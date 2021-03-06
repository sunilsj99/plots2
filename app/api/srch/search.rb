require 'grape'
require 'grape-entity'

module Srch
  class Search < Grape::API
    # we are using a group of reusable parameters using a shared params helper
    # see /app/api/srch/shared_params.rb
    helpers SharedParams

    # Endpoint definitions
    resource :srch do
      # Request URL should be /api/srch/all?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', hidden: false,
                                                          is_array: false,
                                                          nickname: 'srchGetAll'
      params do
        use :common
      end
      get :all do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:all, params)
        results_list = []

        if results.present?
          results_list << results[:profiles].map do |model|
            DocResult.new(
              doc_type: 'USERS',
              doc_url: '/profile/' + model.name,
              doc_title: model.username
            )
          end

          results_list << results[:notes].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:wikis].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'WIKIS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:tags].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'TAGS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:maps].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          results_list << results[:questions].map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'QUESTIONS',
              doc_url: model.path(:question),
              doc_title: model.title,
              score: model.answers.length
            )
          end
          DocList.new(results_list.flatten, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/profiles?srchString=QRY[&sort_by=recent&order_direction=desc&field=username]
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of profiles', hidden: false,
                                           is_array: false,
                                           nickname: 'srchGetProfiles'

      params do
        use :common, :sorting, :ordering, :field
      end
      get :profiles do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:profiles, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_type: 'USERS',
              doc_url: '/profile/' + model.name,
              doc_title: model.username
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/notes?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of research notes', hidden: false,
                                                 is_array: false,
                                                 nickname: 'srchGetNotes'

      params do
        use :common
      end
      get :notes do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:notes, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'NOTES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/wikis?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of wikis pages',    hidden: false,
                                                 is_array: false,
                                                 nickname: 'srchGetWikis'

      params do
        use :common
      end
      get :wikis do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:wikis, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'WIKIS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/questions?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of questions tables', hidden: false,
                                                   is_array: false,
                                                   nickname: 'srchGetQuestions'

      params do
        use :common
      end
      get :questions do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:questions, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'QUESTIONS',
              doc_url: model.path(:question),
              doc_title: model.title,
              score: model.answers.length
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/tags?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of documents associated with tags within the system', hidden: false,
                                                                                   is_array: false,
                                                                                   nickname: 'srchGetByTags'

      params do
        use :common
      end
      get :tags do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:tags, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'TAGS',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/taglocations?srchString=QRY[&tagName=awesome]
      # Note: Query(QRY as above) must have latitude and longitude as srchString=lat,lon
      desc 'Perform a search of documents having nearby latitude and longitude tag values', hidden: false,
                                                                                            is_array: false,
                                                                                            nickname: 'srchGetLocations'

      params do
        use :common, :additional
      end
      get :taglocations do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:taglocations, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path(:items),
              doc_title: model.title,
              score: model.answers.length,
              latitude: model.lat,
              longitude: model.lon,
              blurred: model.blurred?
            )
          end
          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # API TO FETCH QRY RECENT CONTRIBUTORS
      # Request URL should be /api/srch/peoplelocations?srchString=QRY[&tagName=group:partsandcrafts]
      # QRY should be a number
      desc 'Perform a search to show x Recent People',  hidden: false,
                                                        is_array: false,
                                                        nickname: 'srchGetPeople'

      params do
        use :common, :additional
      end
      get :peoplelocations do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:peoplelocations, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.id,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.username,
              latitude: model.lat,
              longitude: model.lon,
              blurred: model.blurred?
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end

      # Request URL should be /api/srch/places?srchString=QRY
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of places',           hidden: false,
                                                   is_array: false,
                                                   nickname: 'srchPlaces'

      params do
        use :common
      end
      get :places do
        search_request = SearchRequest.fromRequest(params)
        results = Search.execute(:places, params)

        if results.present?
          docs = results.map do |model|
            DocResult.new(
              doc_id: model.nid,
              doc_type: 'PLACES',
              doc_url: model.path,
              doc_title: model.title
            )
          end

          DocList.new(docs, search_request)
        else
          DocList.new('', search_request)
        end
      end
    end

    def self.execute(endpoint, params)
      search_type = endpoint
      search_criteria = SearchCriteria.from_params(params)

      if search_criteria.valid?
        ExecuteSearch.new.by(search_type, search_criteria)
      else
        []
      end
    end
  end
end
