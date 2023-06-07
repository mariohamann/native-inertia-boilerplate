<script setup lang="ts">
import { router } from "@inertiajs/vue3";

let props = defineProps<{
	time: string;
}>();

const handleClick = () => {
	const start = Date.now().toString();
	window["start"] = start;
	router.get("/");
	console.count("fetch" + start);
};

if (window.localStorage.getItem("start")) {
	const start = parseInt(window["start"]);
	const now = Date.now();
	const diff = now - start;
	if (diff < 10000) {
		router.get("/");
		console.count("fetch" + start);
	}
}
</script>

<template>
	<header></header>

	<main>
		<h1>Loaded: {{ props.time }}</h1>
		<button @click="handleClick">Loop it!</button>
	</main>
</template>

<style scoped>
a {
	display: block;
	margin-bottom: 0.25rem;
}
</style>
