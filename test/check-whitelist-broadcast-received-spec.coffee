http = require 'http'
CheckWhitelistBroadcastReceived = require '../'

describe 'CheckWhitelistBroadcastReceived', ->
  beforeEach ->
    @whitelistManager =
      checkBroadcastReceived: sinon.stub()

    @sut = new CheckWhitelistBroadcastReceived
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with toUuid that does not match the auth', ->
      beforeEach (done) ->
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'splat'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkBroadcastReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'green-blue'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job without a from', ->
      beforeEach (done) ->
        @whitelistManager.checkBroadcastReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'green-blue'
            responseId: 'yellow-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 422', ->
        expect(@response.metadata.code).to.equal 422

      it 'should get have the status of Unprocessable Entity', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[422]

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.checkBroadcastReceived.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'dim-green'
            fromUuid: 'ugly-yellow'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@response.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a job that with a device that has an invalid whitelist', ->
      beforeEach (done) ->
        @whitelistManager.checkBroadcastReceived.yields null, false
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'puke-green'
            fromUuid: 'not-so-super-purple'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@response.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the checkBroadcastReceived yields an error', ->
      beforeEach (done) ->
        @whitelistManager.checkBroadcastReceived.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'puke-green'
            fromUuid: 'green-safe'
            responseId: 'purple-green'
        @sut.do job, (error, @response) => done error

      it 'should get have the responseId', ->
        expect(@response.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@response.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@response.metadata.status).to.equal http.STATUS_CODES[500]
