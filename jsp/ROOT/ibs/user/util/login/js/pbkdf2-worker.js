// LOCAL-login wire-proof worker (see index.jsp doLogin()).
//
// PBKDF2-HMAC-SHA512 (120000 rounds) must stay strong to protect the at-rest
// password hash, but running it as one uninterrupted loop can trip a
// browser's "unresponsive script" watchdog even inside a Worker (seen in
// Firefox: "script terminated by timeout"). So instead of calling the
// official CryptoJS.PBKDF2() helper as one black-box call, this reimplements
// its exact outer loop (same HMAC-SHA512 primitive from the vendored
// hmac.js/sha512.js, nothing hand-rolled cryptographically) in small chunks,
// yielding back to the event loop between them via setTimeout.
//
// The result is cached by the caller (index.jsp, localStorage) so this only
// needs to run once per (browser, username) pair - later logins on the same
// device send cachedHashHex and skip straight to the cheap HMAC proof step.
importScripts('core.js', 'x64-core.js', 'sha512.js', 'hmac.js');

var CHUNK_SIZE = 500;

function pbkdf2Chunked(password, saltHex, iterations, onProgress, onDone) {
	var salt = CryptoJS.enc.Hex.parse(saltHex);
	var hmac = CryptoJS.algo.HMAC.create(CryptoJS.algo.SHA512, password);
	// U1 = HMAC(password, salt || INT32BE(1)) - matches Auth_Util.Pbkdf2_Sha512
	var u = hmac.finalize(salt.clone().concat(CryptoJS.lib.WordArray.create([1])));
	hmac.reset();
	var t = u.clone();
	var i = 1;

	function step() {
		var end = Math.min(i + CHUNK_SIZE, iterations);
		for (; i < end; i++) {
			u = hmac.finalize(u); // U_i = HMAC(password, U_(i-1))
			hmac.reset();
			for (var w = 0; w < t.words.length; w++) {
				t.words[w] ^= u.words[w]; // T = U1 xor U2 xor ... xor Uc
			}
		}
		onProgress(i / iterations);
		if (i < iterations) {
			setTimeout(step, 0);
		} else {
			onDone(t.toString(CryptoJS.enc.Hex));
		}
	}
	step();
}

self.onmessage = function (e) {
	var d = e.data;
	try {
		if (d.cachedHashHex) {
			var proof = CryptoJS.HmacSHA512(d.stageToken, d.cachedHashHex).toString(CryptoJS.enc.Hex);
			self.postMessage({ done: true, proof: proof, hashHex: d.cachedHashHex });
			return;
		}
		pbkdf2Chunked(d.password, d.saltHex, d.iterations, function (progress) {
			self.postMessage({ progress: progress });
		}, function (hashHex) {
			var proof2 = CryptoJS.HmacSHA512(d.stageToken, hashHex).toString(CryptoJS.enc.Hex);
			self.postMessage({ done: true, proof: proof2, hashHex: hashHex });
		});
	} catch (err) {
		self.postMessage({ error: err.message || String(err) });
	}
};
