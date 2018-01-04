global class CustomIterableWrapper implements Iterable<sObject> {
	global Iterator<sObject> Iterator() {
		return new CustomIterable();
	}
}