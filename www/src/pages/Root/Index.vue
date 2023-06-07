<script setup lang="ts">
import { router } from "@inertiajs/vue3";

let props = defineProps<{
	time: string;
}>();

let count = window["count"];

const handleClick = () => {
	window["start"] = Date.now().toString();
	window["count"] = 0;
	router.get("/");
};

if (window["start"]) {
	if (Date.now() - parseInt(window["start"]) < 10000) {
		window["count"]++;
		router.get("/");
	}
}
</script>

<template>
	<header></header>

	<main>
		<h1>Loaded: {{ props.time }}</h1>
		<button @click="handleClick">Loop it!</button>
		<h2>{{ count }}</h2>
	</main>
</template>

<style scoped>
a {
	display: block;
	margin-bottom: 0.25rem;
}
</style>
