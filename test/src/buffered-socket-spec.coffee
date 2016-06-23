{beforeEach, describe, it} = global
{expect} = require 'chai'

{EventEmitter} = require 'events'
BufferedSocket = require '../../src/buffered-socket'

describe 'BufferedSocket', ->
  describe 'SRV resolve', ->
    describe 'when constructed with resolveSrv and secure true', ->
      beforeEach ->
        @dns = resolveSrv: sinon.stub()
        @socket = new EventEmitter
        @socketIoClient = sinon.spy(=> @socket)

        options = resolveSrv: true, service: 'meshblu', domain: 'octoblu.com', secure: true
        dependencies = {@dns, @socketIoClient}

        @sut = new BufferedSocket options, dependencies

      describe 'when connect is called', ->
        beforeEach 'making the request', (done) ->
          @dns.resolveSrv.withArgs('_meshblu._socket-io-wss.octoblu.com').yields null, [{
            name: 'mesh.biz'
            port: 34
            priority: 1
            weight: 100
          }]
          @sut.connect done
          @socket.emit 'connect'

        it 'should call request with the resolved url', ->
          expect(@socketIoClient).to.have.been.calledWith 'wss://mesh.biz:34'

    describe 'when constructed with resolveSrv and secure false', ->
      beforeEach ->
        @dns = resolveSrv: sinon.stub()
        @socket = new EventEmitter
        @socketIoClient = sinon.spy(=> @socket)

        options = resolveSrv: true, service: 'meshblu', domain: 'octoblu.com', secure: false
        dependencies = {@dns, @socketIoClient}

        @sut = new BufferedSocket options, dependencies

      describe 'when connect is called', ->
        beforeEach 'making the request', (done) ->
          @dns.resolveSrv.withArgs('_meshblu._socket-io-ws.octoblu.com').yields null, [{
            name: 'insecure.xxx'
            port: 80
            priority: 1
            weight: 100
          }]
          @sut.connect done
          @socket.emit 'connect'

        it 'should call request with the resolved url', ->
          expect(@socketIoClient).to.have.been.calledWith 'ws://insecure.xxx:80'

    describe 'when constructed without resolveSrv', ->
      beforeEach ->
        @socket = new EventEmitter
        @socketIoClient = sinon.spy(=> @socket)

        options = resolveSrv: false, protocol: 'wss', hostname: 'thug.biz', port: 123
        dependencies = {@socketIoClient}

        @sut = new BufferedSocket options, dependencies

      describe 'when connect is called', ->
        beforeEach 'making the request', (done) ->
          @sut.connect done
          @socket.emit 'connect'

        it 'should call request with the formatted url', ->
          expect(@socketIoClient).to.have.been.calledWith 'wss://thug.biz:123'
