# -*- coding: utf-8 -*-
#  Copyright (C) 2015 Toru Nagashima
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

expect = require('chai').expect
harmony = require '../third_party/esprima'
escope = require '..'

describe 'References:', ->
    it '"let a = 0;" should have a writable reference on global.', ->
        ast = harmony.parse """
        let a = 0;
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 1

        scope = scopeManager.scopes[0]
        expect(scope.variables).to.have.length 1
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.equal scope.variables[0]
        expect(reference.writeExpr).to.not.be.undefined
        expect(reference.isWrite()).to.be.true
        expect(reference.isRead()).to.be.false

    it '"let a = 0;" should have a writable reference in function.', ->
        ast = harmony.parse """
        function foo() {
            let a = 0;
        }
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 2  # [global, foo]

        scope = scopeManager.scopes[1]
        expect(scope.variables).to.have.length 2  # [arguments, a]
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.equal scope.variables[1]
        expect(reference.writeExpr).to.not.be.undefined
        expect(reference.isWrite()).to.be.true
        expect(reference.isRead()).to.be.false

    it '"const a = 0;" should have a writable reference on global.', ->
        ast = harmony.parse """
        const a = 0;
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 1

        scope = scopeManager.scopes[0]
        expect(scope.variables).to.have.length 1
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.equal scope.variables[0]
        expect(reference.writeExpr).to.not.be.undefined
        expect(reference.isWrite()).to.be.true
        expect(reference.isRead()).to.be.false

    it '"const a = 0;" should have a writable reference in function.', ->
        ast = harmony.parse """
        function foo() {
            const a = 0;
        }
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 2  # [global, foo]

        scope = scopeManager.scopes[1]
        expect(scope.variables).to.have.length 2  # [arguments, a]
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.equal scope.variables[1]
        expect(reference.writeExpr).to.not.be.undefined
        expect(reference.isWrite()).to.be.true
        expect(reference.isRead()).to.be.false

    it '"var a = 0;" should not have references on global.', ->
        ast = harmony.parse """
        var a = 0;
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 1

        scope = scopeManager.scopes[0]
        expect(scope.variables).to.have.length 1
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.be.null  # the references of var declarations on global don't resolve because those are dynamic.
        expect(reference.writeExpr).to.not.be.undefined
        expect(reference.isWrite()).to.be.true
        expect(reference.isRead()).to.be.false

    it '"var a = 0;" should have a writable reference in function.', ->
        ast = harmony.parse """
        function foo() {
            var a = 0;
        }
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 2  # [global, foo]

        scope = scopeManager.scopes[1]
        expect(scope.variables).to.have.length 2  # [arguments, a]
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.equal scope.variables[1]
        expect(reference.writeExpr).to.not.be.undefined
        expect(reference.isWrite()).to.be.true
        expect(reference.isRead()).to.be.false

    it '"function a() {} a();" should not have references on global.', ->
        ast = harmony.parse """
        function a() {}
        a();
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 2  # [global, a]

        scope = scopeManager.scopes[0]
        expect(scope.variables).to.have.length 1
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.be.null  # the references of var declarations on global don't resolve because those are dynamic.
        expect(reference.isWrite()).to.be.false
        expect(reference.isRead()).to.be.true

    it '"function a() {} a();" should have a readable reference in function.', ->
        ast = harmony.parse """
        function foo() {
            function a() {}
            a();
        }
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 3  # [global, foo, a]

        scope = scopeManager.scopes[1]
        expect(scope.variables).to.have.length 2  # [arguments, a]
        expect(scope.references).to.have.length 1

        reference = scope.references[0]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'a'
        expect(reference.resolved).to.equal scope.variables[1]
        expect(reference.isWrite()).to.be.false
        expect(reference.isRead()).to.be.true

    it '"class A {} new A();" should have a readable reference on global.', ->
        ast = harmony.parse """
        class A {}
        let a = new A();
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 2  # [global, A]

        scope = scopeManager.scopes[0]
        expect(scope.variables).to.have.length 2  # [A, a]
        expect(scope.references).to.have.length 2  # [a, A]

        reference = scope.references[1]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'A'
        expect(reference.resolved).to.equal scope.variables[0]
        expect(reference.isWrite()).to.be.false
        expect(reference.isRead()).to.be.true

    it '"class A {} new A();" should have a readable reference in function.', ->
        ast = harmony.parse """
        function foo() {
            class A {}
            let a = new A();
        }
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 3 # [global, foo, A]

        scope = scopeManager.scopes[1]
        expect(scope.variables).to.have.length 3  # [arguments, A, a]
        expect(scope.references).to.have.length 2  # [a, A]

        reference = scope.references[1]
        expect(reference.from).to.equal scope
        expect(reference.identifier.name).to.equal 'A'
        expect(reference.resolved).to.equal scope.variables[1]
        expect(reference.isWrite()).to.be.false
        expect(reference.isRead()).to.be.true

# vim: set sw=4 ts=4 et tw=80 :
