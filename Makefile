all: clean compile

deps:
	rebar get-deps update-deps

clean:
	rebar clean

compile: clean deps
	rebar compile escriptize

dialyze: clean
	dialyzer -I ./include --src -r ./src \
		-Werror_handling -Wrace_conditions -Wunderspecs

dialyzer-setup:
	dialyzer --build_plt --apps erts kernel stdlib crypto \
		sasl common_test eunit compiler \
		| fgrep -v dialyzer.ignore

dev:
	erl -pa ./ebin -I ./include -s crypto -smp \
		-setcookie swirl -sname swirl \
		+K true +A 16 \
		-s swirl -s swirl help

console:
	erl -pa ./ebin -I ./include -s crypto -smp \
		-setcookie swirl -sname console \
		+K true +A 16 \
		-s swirl -s swirl help

run:
	./swirl
