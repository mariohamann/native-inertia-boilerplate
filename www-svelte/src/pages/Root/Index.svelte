<script lang="ts">
	import { router } from "@inertiajs/svelte";
	import { writable } from "svelte/store";

	export let time: string;

	const start = writable(null);

	const count = writable(0);

	const handleClick = () => {
		count.set(0);
		start.set(Date.now().toString());
		router.get("/");
	};

	router.on("success", (event) => {
		if ($start) {
			count.set($count + 1);
			if (Date.now() - parseInt($start) < 10000) {
				router.get("/");
			}
		}
	});
</script>

<header />

<main>
	<h1>Loaded: {time}</h1>
	<button on:click={handleClick}>Loop it!</button>
	<h2>Count: {$count}</h2>
</main>

<style>
	a {
		display: block;
		margin-bottom: 0.25rem;
	}
</style>
